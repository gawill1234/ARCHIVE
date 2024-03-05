class Collection
  def self.restore_saved_collection(name, source_directory)
    coll = Collection.new(name)

    # TODO: Allow this script to run from Windows.

    # Should always reset the configuration to the provided one
    # Should we stop / restart the services as well?

    # If the status doesn't match the saved status, then let's reset everything

    # TODO: Check the status

    coll.delete
    coll.create

    # Set the configuration (if it was saved).
    old_xml = nil
    begin
      File.open("#{source_directory}/config.xml") {|f|
        old_xml = Nokogiri::XML(f)
      }
    rescue
    end

    # If we got a vse-collection configuration, fix it's name and set it.
    if old_xml and old_xml.root.name == 'vse-collection'
      old_xml.root['name'] = name
      coll.set_xml(old_xml)
    end

    files = Array.new
    files += Dir.glob("#{source_directory}/crawl*/indexer.sqlt")
    files += Dir.glob("#{source_directory}/crawl*/log.sqlt")
    files += Dir.glob("#{source_directory}/crawl*/cache.sqlt")
    files += Dir.glob("#{source_directory}/crawl*/viv_idx_*")
    # TODO: Copy wildcard dictionaries
    # TODO: Copy the status

    # Just in case, don't copy the same file twice
    files.uniq!

    # Remove the source directory from the path,
    # in case we are renaming the collection.
    files = files.map {|f| f.sub(/^#{source_directory}/, '')}

    # Get a list of the unique directory names.
    dirs = files.map {|path| path.split('/')[0..-2].join('/') }.uniq

    gronk = Gronk.new
    if TESTENV.windows
      copy_command = 'copy'
      mkdir_command = 'mkdir'
      # Tell Windows how to authenticate to the file server...
      gronk.execute('net use \\\\netapp1a.bigdatalab.ibm.com\testbed5-data ' +
                    '/user:BIGDATALAB\qasamba Must@ng5', 'xml')
      # Make our Linux paths into Windows paths.
      remote_source_directory = '\\\\netapp1a.bigdatalab.ibm.com\testbed5-data\\' +
        source_directory.split('/')[2..-1].join('\\')
      files.map! {|path| path.split('/').join('\\')}
      dirs.map! {|path| path.split('/').join('\\')}
    else
      copy_command = '/bin/cp -f'
      mkdir_command = '/bin/mkdir -p'
      remote_source_directory = source_directory
    end

    # Make the directories...
    dest_directory = coll.filebase
    dirs.each do |path|
      cmd = [mkdir_command, dest_directory + path].join(' ')
      gronk.execute(cmd, 'xml')
    end

    # Copy the files in...
    files.each do |path|
      msg('Updating collection %s file %s' % [coll.name, path])
      src_path = remote_source_directory + path
      dest_path = dest_directory + path
      cmd = [copy_command, src_path, dest_path].join(' ')
      begin
        gronk.execute(cmd, 'xml')
      rescue EOFError => ex
        STDERR.puts "Ignoring error:"
        STDERR.puts "#{ex.class}: #{ex.message}"
        STDERR.puts "Backtrace:"
        STDERR.puts ex.backtrace
      end
    end

    # Poke the collection to see if it worked
    coll.search

    return coll
  end
end
