#!/usr/bin/env python

# The character encoding of the command line arguments passed to this script
# and the text files read by this script (needed for accurate tokenization).
CHARACTER_ENCODING = 'UTF-8'

# Load the required standard library modules.
import re
import os
import sys
import fnmatch
import sqlite3

def mungepath(p):
  return os.path.abspath(os.path.expanduser(p))

# Parse the command line arguments.
script_name = os.path.split(sys.argv[0])[1]
if len(sys.argv) < 4:
  sys.stderr.write("%s: Not enough arguments!\n" % script_name)
  sys.exit(1)
database_file = mungepath(sys.argv[1])
user_directory = mungepath(sys.argv[2])
shadow_directory = mungepath(sys.argv[3])
keywords = ' '.join(sys.argv[4:]).decode(CHARACTER_ENCODING)

# Open the SQLite database (creating it if it didn't already exist).
first_use = not os.path.exists(database_file)
connection = sqlite3.connect(database_file)
connection.text_factory = str

# Initialize the database schema?
if first_use:
  connection.execute('create table if not exists files (file_id integer primary key, filename text, last_modified integer)')
  connection.execute('create table if not exists keywords (keyword_id integer primary key, value text)')
  connection.execute('create table if not exists occurrences (file_id integer, keyword_id integer, primary key (file_id, keyword_id))')

# Function to scan a single text file for keywords.

UNSAVED_CHANGES = False
CACHED_KEYWORDS = {}

def scan_note(note):
  global UNSAVED_CHANGES
  with open(note['filename']) as handle:
    result = connection.execute('select file_id from files where filename = ?', (note['filename'],)).fetchone()
    if result:
      file_id = result[0]
      connection.execute('delete from occurrences where file_id = ?', (file_id,))
      connection.execute('update files set last_modified = ? where file_id = ?', (note['last_modified'], file_id))
    else:
      connection.execute('insert into files (filename, last_modified) values (?, ?)', (note['filename'], note['last_modified']))
      file_id = connection.execute('select last_insert_rowid()').fetchone()[0]
    for keyword in tokenize(handle.read().decode(CHARACTER_ENCODING)):
      if keyword in CACHED_KEYWORDS:
        keyword_id = CACHED_KEYWORDS[keyword]
      else:
        record = connection.execute('select keyword_id from keywords where value = ?', (keyword,)).fetchone()
        if not record:
          connection.execute('insert into keywords (value) values (?)', (keyword,))
          record = connection.execute('select last_insert_rowid()').fetchone()
        keyword_id = record[0]
        CACHED_KEYWORDS[keyword] = keyword_id
      connection.execute('insert into occurrences (file_id, keyword_id) values (?, ?)', (file_id, keyword_id))
    UNSAVED_CHANGES = True

# Function to tokenize text strings into words.

def tokenize(text):
  words = set()
  for word in re.findall(r'\w+', text.lower(), re.UNICODE):
    word = word.strip()
    if word != '' and not word.isspace():
      words.add(word)
  return words

# Scan the filenames and last modified times of all notes on the disk.

notes_on_disk = {}
for directory in user_directory, shadow_directory:
  for filename in os.listdir(directory):
    if not fnmatch.fnmatch(filename, '.*.sw?'): # (Vim swap files are ignored)
      filename = os.path.join(directory, filename)
      notes_on_disk[filename] = dict(filename=filename, last_modified=os.path.getmtime(filename))
if first_use:
  for note in notes_on_disk.itervalues():
    scan_note(note)
else:
  deleted_notes = []
  updated_notes = []
  for file_id, filename, last_modified in connection.execute('select file_id, filename, last_modified from files order by filename'):
    filename = str(filename)
    if filename not in notes_on_disk:
      deleted_notes.append((file_id, filename))
    else:
      note = notes_on_disk[filename]
      del notes_on_disk[filename]
      if note['last_modified'] > last_modified:
        updated_notes.append(note)
  created_notes = notes_on_disk.values()
  for file_id, filename in deleted_notes:
    connection.execute('delete from files where file_id = ?', (file_id,))
    connection.execute('delete from occurrences where file_id = ?', (file_id,))
    UNSAVED_CHANGES = True
  for note in sorted(created_notes + updated_notes, key=lambda x: x['filename']):
    scan_note(note)

# Commit unsaved changes to SQLite database?

if UNSAVED_CHANGES:
  connection.commit()

# Query the database for the given keyword(s) and print the filenames of the
# files that contain all keywords.

if len(keywords) > 0 and not keywords.isspace():
  # TODO Use SQL support for set intersection?!
  query = """
    select filename from files where file_id in (
      select file_id from occurrences where keyword_id in (
        select keyword_id from keywords where value like ?
      )
    ) """
  global_matches = set()
  for keyword in tokenize(keywords):
    current_matches = set()
    for result in connection.execute(query, ('%' + keyword + '%',)):
      filename = str(result[0])
      current_matches.add(filename)
    if len(global_matches) == 0:
      global_matches = current_matches
    else:
      global_matches &= current_matches
  print '\n'.join(sorted(global_matches))

connection.close()
