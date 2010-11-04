#!/usr/bin/env python
# vim: set fileencoding=utf-8 :

import re
import os
import sys
import fnmatch
import sqlite3

# Load my custom English/Dutch stemmer module based on the Snowball stemmer algorithm.
try:
  from stemmer import stem
except ImportError:
  def stem(language, word): return word

# Parse the command line arguments.
script_name = os.path.split(sys.argv[0])[1]
script_args = sys.argv[1:]
if len(script_args) < 2:
  sys.stderr.write("%s: Invalid arguments!\n" % script_name)
  sys.exit(1)
DATABASE_FILE = os.path.expanduser(script_args[0])
NOTES_DIRECTORY = os.path.expanduser(script_args[1])
keywords = ' '.join(script_args[2:])

# Initialize the SQLite database connection handle.
FIRST_USE = not os.path.exists(DATABASE_FILE)
connection = sqlite3.connect(DATABASE_FILE)

# Initialize the database schema?
if FIRST_USE:
  connection.execute('create table if not exists files (file_id integer primary key, filename text, last_modified integer)')
  connection.execute('create table if not exists keywords (keyword_id integer primary key, value text)')
  connection.execute('create table if not exists occurrences (file_id integer, keyword_id integer, primary key (file_id, keyword_id))')

# Update keywords for changed notes.
UNSAVED_CHANGES = False
CACHED_KEYWORDS = {}
NUM_SCANNED_NOTES = 0

def scan_note(note):
  global UNSAVED_CHANGES, NUM_SCANNED_NOTES
  sys.stderr.write("%s: Scanning note %i: %s\n" % (script_name, NUM_SCANNED_NOTES + 1, note['filename']))
  with open(note['pathname']) as handle:
    encoded_name = sqlite3.Binary(note['filename'])
    result = connection.execute('select file_id from files where filename = ?', (encoded_name,)).fetchone()
    if result:
      file_id = result[0]
      connection.execute('delete from occurrences where file_id = ?', (file_id,))
      connection.execute('update files set last_modified = ? where file_id = ?', (note['last_modified'], file_id))
    else:
      connection.execute('insert into files (filename, last_modified) values (?, ?)', (encoded_name, note['last_modified']))
      file_id = connection.execute('select last_insert_rowid()').fetchone()[0]
    for root, keyword in tokenize(handle.read().decode('UTF-8')):
      keyword_id = find_keyword(root)
      connection.execute('insert into occurrences (file_id, keyword_id) values (?, ?)', (file_id, keyword_id))
    UNSAVED_CHANGES = True
    NUM_SCANNED_NOTES += 1

def tokenize(text):
  """
  """
  words = {}
  for word in re.findall(r'\w+', text.lower(), re.UNICODE):
    word = word.strip()
    if word != '' and not word.isspace():
      word = word.encode('UTF-8')
      root = stem('dutch', word)
      if root == word:
        root = stem('english', word)
      words[root] = word
  return words.iteritems()

def find_keyword(keyword):
  if keyword in CACHED_KEYWORDS:
    return CACHED_KEYWORDS[keyword]
  else:
    encoded_keyword = sqlite3.Binary(keyword)
    record = connection.execute('select keyword_id from keywords where value = ?', (encoded_keyword,)).fetchone()
    if not record:
      connection.execute('insert into keywords (value) values (?)', (encoded_keyword,))
      record = connection.execute('select last_insert_rowid()').fetchone()
    keyword_id = record[0]
    CACHED_KEYWORDS[keyword] = keyword_id
    return keyword_id

# Scan filenames and last modified times of notes on disk.
notes_on_disk = {}
for filename in os.listdir(NOTES_DIRECTORY):
  if not fnmatch.fnmatch(filename, '.*.sw?'): # (Vim swap files are ignored)
    pathname = os.path.join(NOTES_DIRECTORY, filename)
    notes_on_disk[filename] = { 'filename': filename, 'pathname': pathname, 'last_modified': os.path.getmtime(pathname) }
if FIRST_USE:
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
    sys.stderr.write("Deleting %s\n" % filename)
    connection.execute('delete from files where file_id = ?', (file_id,))
    connection.execute('delete from occurrences where file_id = ?', (file_id,))
    UNSAVED_CHANGES = True
  for note in sorted(created_notes + updated_notes, key=lambda x: x['filename']):
    scan_note(note)

if UNSAVED_CHANGES:
  sys.stderr.write("%s: Committing changes to %s\n" % (script_name, DATABASE_FILE))
  connection.commit()

if keywords != '' and not keywords.isspace():
  query = """
    select filename from files where file_id in (
      select file_id from occurrences where keyword_id in (
        select keyword_id from keywords where value like ?
      )
    ) """
  global_matches = set()
  for root, keyword in tokenize(keywords):
    encoded_keyword = sqlite3.Binary(root)
    keyword_matches = set()
    for result in connection.execute(query, (encoded_keyword,)):
      filename = str(result[0])
      keyword_matches.add(filename)
    if len(global_matches) == 0:
      global_matches = keyword_matches
    else:
      global_matches &= keyword_matches
  if len(global_matches) == 0:
    sys.stderr.write("%s: No matches found!\n" % script_name)
  else:
    print '\n'.join(sorted(global_matches, key=str.lower))
elif not UNSAVED_CHANGES:
  sys.stderr.write("%s: Nothing to do!\n" % script_name)

connection.close()
