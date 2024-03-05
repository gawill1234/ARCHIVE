#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT']+'/lib'

require 'gronk'
require 'time'

SKIP_FILES = [ /crawler-fatal-error$/,
               /crawler-read-only$/,
               /crawler.log$/,
               /crawler-service.pipe$/,
               /indexer-fatal-error$/,
               /indexer-read-only$/,
               /indexer.log$/,
               /indexer-service.pipe$/,
               /\/tmp$/,          # Avoid bug 22988
               /\/tmp\/viv_dis_/, # Avoid bug 22988
               /\/tmp\/viv_en_/ ] # Avoid bug 22988

def windows_path(path)
  not path[/^[A-Za-z]:\\/].nil?
end

def fix_path(path)
  # If it looks like we have a Windows path,
  if windows_path(path)
    # fixup any Unix-like slashes.
    path.split('/').join('\\')
  else
    path
  end
end

def file_list(remote_path_list, skip_files=nil)
  gronk = Gronk.new
  windows = windows_path(remote_path_list[0])
  lsR = 'ls -R'
  lsR = 'dir /b /s' if windows
  list = []
  remote_path_list.each do |run_path|
    base = run_path
    o = gronk.execute("#{lsR} \"#{run_path}\"")
    o.split("\n").each do |path|
      if windows
        if path.strip != "File Not Found"
          # We get full paths (which we want) from Windows.
          list << path.strip # May have carriage return (\r) to strip off.
        end
      else if path[/^\/.*:$/]
             # Linux and Solaris give us directory headers.
             base = path[0..-2]
           else if path != ""
                  # Put the directory and file name together.
                  list << "#{base}/#{path}"
                end
           end
      end
    end
  end
  if skip_files
    list = list.reject {|path| skip_files.any? {|re| path =~ re }}
  end
  list
end

# Wrap Gronk, mostly so we don't blow up on failure.
def file_time(path, date='modified')
  begin
    Gronk.new.file_time(path, date)
  rescue
    nil
  end
end

def time_file_list(remote_path_list, skip_files=nil)
  file_list(remote_path_list, skip_files).map {|path|
    [file_time(path), path] }.reject {|t,p| t.nil?}.sort
end

def last_modified(remote_path_list, skip_files=nil)
  time_file_list(remote_path_list, skip_files).max
end

def files_newer_than(remote_path_list, base_time=nil, skip_files=nil)
  tfl = time_file_list(remote_path_list, skip_files)
  tfl.select {|t,p| base_time.nil? or t > base_time} if tfl.length > 0
end

def fail_files_newer(collection, skip_files=SKIP_FILES)
  acquired = collection.read_only['acquired']
  return [false, "read-only never 'acquired'"] if acquired.nil?
  description = "No files changed after #{acquired}"
  acquired = Time.iso8601(acquired)
  modified_file_list = files_newer_than(collection.crawl_path_list,
                                        acquired,
                                        skip_files)
  return [false,
          "Test infrastructure failure:" +
          " couldn't get last file change time stamp."
         ] if modified_file_list.nil?
  windows = windows_path(modified_file_list[0][1]) if
    not modified_file_list.empty?
  formatted_list = modified_file_list.map {|t,p| "#{t.iso8601} #{p}"}.join("\n")
  if formatted_list != ''
    description = "Files changed after #{acquired.iso8601}"
    description += " (meaningless on Windows)" if windows
    description += ". Paths are:\n#{formatted_list}"
  end
  [(modified_file_list.length == 0 or windows), description]
end

def detail_read_only(path_list, file_name)
  file_list = path_list.map {|path| fix_path("#{path}/#{file_name}")}
  file_list.map {|path| file_time(path)}.max
end

def crawler_read_only(collection)
  detail_read_only(collection.run_path_list, 'crawler-read-only')
end

def indexer_read_only(collection)
  detail_read_only(collection.run_path_list, 'indexer-read-only')
end

if __FILE__ == $0
  require 'collection'
  remote_path_list = Collection.new(ARGV[0]).run_path_list
  raise "No run paths found #{remote_path_list}" if
    remote_path_list.nil? or remote_path_list == []
  # Spit out files newer than ten minutes old...
  files_newer_than(remote_path_list, Time.new-600).each do |t,p|
    puts "#{t} #{p}"
  end
end
