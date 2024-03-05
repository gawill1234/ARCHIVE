#!/usr/bin/env ruby

DEFAULT_TIMELIMIT = 30

# 'vtd' supports a bunch of options that we don't typically use.
# This parser silently ignores options other than "type=" and "run=".

def vtd_contents(vtd_file)
  retlist = []
  open(vtd_file, 'r') {|f|
    f.each {|line|
      # Simply ignore the "bogus" tests.
      unless line[/type=[^+]/i] or line.length < 3
        run = line[/run=[0-9]+/i]
        if run
          timelimit = run.split('=')[1].to_i/60 # convert seconds to minutes
        else
          timelimit = DEFAULT_TIMELIMIT
        end
        command = line[/[^()]+$/].strip
        # Pick out the file name.
        test = command[/[^ (=)\/]{4,}[a-z][^ (=)\/]+/] # This is pretty loose...
        name = File.basename(test, test[/\.[^.]*$/] || '.tst')
        retlist << [name, command, timelimit]
      end
    }
  }
  retlist
end

if __FILE__ == $0
  ARGV.each{|arg|
    item = vtd_contents(arg)
    item.each {|name,cmd,time| puts '(run=%d)%s' % [60*time, cmd]}
  }
end
