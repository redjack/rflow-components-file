# RFlow-Components-File

[![Build Status](https://travis-ci.org/redjack/rflow-components-file.png?branch=master)](https://travis-ci.org/redjack/rflow-components-file)

A gem containing File-specific components and data types for RFlow
(https://github.com/redjack/rflow).

## Data Types

* `RFlow::Message::Data::File` - an file data type with associated
  `stat`-like metadata and file content

## Directory Watcher

The directory watcher component
(`RFlow::Components::File::DirectoryWatcher`) implements a
polling-based directory monitor that, when it notices new files in a
configured directory, reads them into either a
`RFlow::Message::Data::File` (content + metadata) or a
`RFlow::Message::Data::Raw` and sends the messages out the `file_port`
or `raw_port`, respectively.  The watcher then deletes the file from disk.

### Configuration

* 'directory_path'  => '/tmp/import'
* 'file_name_glob'  => '*'
* 'poll_interval'   => 1
* 'files_per_poll'  => 1
* 'remove_files'    => true

### Limitations

* Obviously, since the entire file is read into an RFlow message,
  memory is a concern.

* The RFlow application needs to have permissions to delete files in
  the configured directory ... it will crash (fail fast!) otherwise.

## File Output

The only component currently implemented for file output
(`RFlow::Components::File::OutputRawToFiles`) does so via
`RFlow::Message::Data::Raw` messages to its `raw_port`. Based on the
configuration, the component will create a file name for the output
(using a `file_name_prefix`, timestamp, entropy, and
`file_name_suffix`), and then write the raw message data as the file
content.

### Configuration

* 'directory_path'  => '/tmp'
* 'file_name_prefix' => 'output.'
* 'file_name_suffix' => '.out'

## License

   Copyright 2014 RedJack LLC

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
