#!/usr/bin/env ruby

require 'open-uri'
require 'fileutils'
require 'find'
require 'misc'
require 'velocity/reset'
include Velocity

class TestRunner
  def initialize(runid)
    @runid = runid.to_i
    @server = 'http://localhost:%d/test' % [1000+@runid]
  end

  # Return the directory path that contains a file.
  # Raise an exception if the file is not found or is found more than once.
  def get_test_dir
    # Gather a list of paths for the given file name.
    l = []
    Find.find(ENV['TEST_ROOT'] + '/tests'){|path|
      l << path if File.basename(path) == @test
    }
    # Predetermined results if we can't find exactly one test.
    @result = :absent    if l.length == 0
    @result = :ambiguous if l.length > 1
    # Note that @path will be an empty string if the test wasn't found.
    @path = l.map {|p| File.dirname(p)}.join(' ')
  end

  def test_info(id, name, command, timelimit)
    @result = nil
    @id = id
    @name = name
    @command = command
    @timelimit = timelimit.to_i
    @test = @command[/[^ (=)\/]{4,}[a-z][^ (=)\/]+/] # This is pretty loose...
    get_test_dir                # sets @path, also @result for failure only.
    @command
  end

  def get_next_test
    # Ask the test server for the next test I should run.
    # Returns test command line and time limit
    t = open('%s/next?id=%d' % [@server, @runid]) {|f| f.read}
    test_info(*eval(t)) if t.length > 9
  end

  def report_test_start
    msg "#{@command}: start"
    t = open('%s/start?id=%d&command=%s&name=%s&srcpath=%s&logpath=%s' %
             [@server,
              @id,
              @command.split(' ').join('+'),
              @name,
              @path.split(' ').join('+'),
              Dir.getwd]) {|f| f.read}
  end

  def report_test_finish
    msg "#{@command}: #{@result}"
    t = open('%s/finish?id=%d&command=%s&result=%s' %
             [@server,
              @id,
              @command.split(' ').join('+'),
              @result]) {|f| f.read}
    @result
  end

  def timed_run
    report_test_start
    timeout_filename = '%s.timeout' % @name
    pid = fork {
      # Make this new process a process group leader, to make it easy to kill.
      Process.setpgrp
      thread = Thread.new {
        system('bash', '-c', '%s > %s.stdout 2> %s.stderr' %
               [@command, @name, @name])
      }
      if thread.join(60*@timelimit)
        exit 0 if thread.value  # passed
        exit 1                  # failed
      else                      # timeout
        # The timeout is in minutes.
        exceed = "%d minutes" % @timelimit
        # When we have a whole number of hours, talk about hours.
        if @timelimit % 60 == 0
          exceed = @timelimit == 60 ? "one hour" : "%d hours" % (@timelimit/60)
        end
        open(timeout_filename, 'w') {|f|
          f.write("%s Test killed due to timeout. Run time exceeded %s.\n" %
                  [Time.now.strftime('%H:%M:%S'), exceed])
        }
        # Hard kill myself and all of my children.
        Process.kill(-9, 0)
      end
      # Should not ever get here.
      exit 2
    }
    status = Process.wait2(pid)[1]
    @result = :crashed
    if status.exited?
      # Clean exit. Status code indicates pass/fail.
      @result = [:passed, :failed][status.exitstatus]
    elsif File.exist?(timeout_filename)
      @result = :timedout
    else
      # Record the termination signal and what time we saw it.
      open('%s.termsig' % @name, 'w') {|f|
        f.write("%s Test terminated by signal %d.\n" %
                [Time.now.strftime('%H:%M:%S'), status.termsig])
      }
      # SIGKILL or SIGTERM means an outsider aborted the test run.
      @result = :aborted if status.termsig == 9 or status.termsig == 15
    end
    report_test_finish
  end

  def run_test
    if @result
      # If we already have a result (which will be a failure) just report it.
      report_test_start
      report_test_finish
    else
      # Make sure to use a new directory name.
      addon = 0
      mydir = @name
      while File.exist?(mydir)
        addon += 1
        mydir = '%s-%d' % [@name, addon]
      end

      # Won't follow symlinks: FileUtils.cp_r(@path+'/.',mydir,:preserve=>true)
      system('rsync', '-rLpt', @path+'/.', mydir)
      @result = Dir.chdir(mydir){
        # reset the target system
        File.open('%s.reset'%@name, 'w') {|f| Velocity::reset(f)}
        timed_run                 # run the test, with reporting and timeout.
      }
      FileUtils.rm_rf(mydir) if @result == :passed
    end
    @result
  end
end

if __FILE__ == $0
  tr = TestRunner.new(ARGV[0])

  if ARGV.length > 1
    # Run any tests specifically listed on the command line.
    # This isn't exactly useful...
    ARGV[1..-1].each{|arg|
      tr.test_info(20, arg)
      tr.run_test
    }
  else
    # While the server has work for us, do it.
    while tr.get_next_test
      tr.run_test
    end
  end
end
