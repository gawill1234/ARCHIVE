#!/usr/bin/env ruby

require 'socket'

module Velocity
  def cb_ignore_all(vapi, cbs, out)
    # Tell the broker to ignore every collection it is currently watching.
    # Return a list of collection names that were ignored.
    cbs.xpath('/collection-broker-status-response' +
              '/collection[@is-ignored="false"]/@name').map do |name|
      begin
        vapi.collection_broker_ignore_collection(:collection => name)
        name.to_s
      rescue
        # When would this happen??
        msg("Ignore collection '#{name}' failed? ", out)
        nil
      end
    end
  end

  def reset_cb(vapi, out)
    cbs = nil
    # Get the collection broker's world view.
    begin
      cbs = vapi.collection_broker_status
    rescue => exception
      msg("Couldn't get collection-broker-status:", out)
      msg(exception, out)
      msg("No collection-broker cleanup attempted.", out)
      return
    end
    ignored = cb_ignore_all(vapi, cbs, out)
    msg("Ignored collections: #{ignored.inspect}", out) unless ignored.empty?
    vapi.collection_broker_set(
      :configuration => '<collection-broker-configuration name="global"/>')
  end

  def reset(out = $stdout)
    msg('Resetting target system:', out)
    gronk = Gronk.new
    vapi = Vapi.new(TESTENV.velocity, TESTENV.user, TESTENV.password)
    reset_cb(vapi, out)
    # FIXME This has several shortcomings.  It doesn't understand
    # directories being in non-standard locations (due to
    # vivisimo.conf).  It should run the command line via 'gronk',
    # especially on Windows, to get Velocity run-time user context for
    # any mounted drives.
    idir = gronk.installed_dir
    vshut = fix_path(idir + '/bin/velocity-shutdown') + ' --force --yes'
    qs_xml = fix_path(idir + '/data/query-service.xml')
    vstart = fix_path(idir + '/bin/velocity-startup') + ' --yes'
    cmd = if TESTENV.os == :linux
            ['ssh', '-F', "#{ENV['TEST_ROOT']}/files/ssh_config",
             "root@#{TESTENV.host}",
             "#{vshut}; rm -f #{qs_xml}; rm -vf $(find #{idir}/data -name \"*.run\"); #{vstart}"]
          elsif TESTENV.os == :solaris
            ['ssh', '-F', "#{ENV['TEST_ROOT']}/files/ssh_config",
             "root@#{TESTENV.host}",
             "#{vshut}; rm -f #{qs_xml}; runfiles=$(find #{idir}/data -name \"*.run\"); echo \"$runfiles\"; [ \"$runfiles\" ] && rm -f $runfiles; #{vstart}"]
          elsif TESTENV.os == :windows
            ['ssh', '-F', "#{ENV['TEST_ROOT']}/files/ssh_config",
             "administrator@#{TESTENV.host}", 'cmd', '/c',
             vshut, '&&',
             "del #{qs_xml} 2> nul:", '&&',
             "cd #{idir}\\data", '&&',
             'del /s *.run', '&&',
             vstart]
          else
            ['echo', 'Unknown target OS', TESTENV.os]
          end
    cmdstr = "'" + cmd.join("' '") + "'"
    response = %x[#{cmdstr}]
    msg(cmdstr + "\n" + response, out)
    # Attempt to tickle out all of the "terminated unexpectedly" messages
    # This may try to get status for collections that don't exist,
    # for example "collection-broker" (when I see a run file).
    response.scan(/[^\/*\\]+\.run/).each {|run_name|
      name = run_name[0..-5]
      msg("tickling collection #{name}", out)
      vapi.search_collection_status(:collection => name) rescue next}

    myip = UDPSocket.open{|s| s.connect("10.1.1.1", 1); s.addr.last}
    # If either of these fails, we're dead...
    vapi.search_service_set(:configuration => '<vse-qs>
  <vse-qs-option>
    <port>7205</port>
    <allow-ips>127.0.0.1 %s 192.168.0.45</allow-ips>
    <min-idle-threads>0</min-idle-threads>
    <max-idle-threads>5</max-idle-threads>
  </vse-qs-option>
</vse-qs>' % myip)
    vapi.search_service_start   # If this fails, we're dead...
    msg("Reset complete.", out)
  end
end

if __FILE__ == $0
  include Velocity
  require 'misc'
  Velocity::reset
end
