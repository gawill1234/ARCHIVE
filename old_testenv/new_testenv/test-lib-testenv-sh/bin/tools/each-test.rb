#!/usr/bin/env ruby

require 'set'
require 'fileutils'
require 'results'

SECONDS_PER_DAY = 24*60*60
def day_at(time)
  Time.at((time.to_i/SECONDS_PER_DAY).to_i * SECONDS_PER_DAY)
end

HTML_START =  '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
	  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
  <title>%s</title>
    <link rel="stylesheet" type="text/css" href="/tablesorter/themes/blue/style.css" />
    <!--[if IE]><script language="javascript" type="text/javascript" src="/flot/excanvas.min.js"></script><![endif]-->
    <script language="javascript" type="text/javascript" src="/flot/jquery.js" ></script>
    <script language="javascript" type="text/javascript" src="/flot/jquery.flot.js" ></script>
    <script language="javascript" type="text/javascript" src="/tablesorter/jquery.tablesorter.js" ></script>
<script language="javascript" type="text/javascript" id="source">
  $(function() {
    $("#history").tablesorter({sortList:[%s], widgets: ["zebra"]});
  });
</script>
</head>
<body>
<h1>%s</h1>
'

def test_page(f, my_results, trr, prev_name=nil, next_name=nil)
  summary = 'Test Run History for %s' % my_results.first.name
  f.write(HTML_START % [my_results.first.name, '[1,1]', summary])

  f.write('<a name="top"><table width="100%"><tr>')
  f.write('<th align="left"><a href="%s.html">&larr; %s &larr;</a></th>' %
          ([prev_name]*2)) if prev_name
  f.write('<th><a href=".">&uarr; Index &uarr;</a></th>')
  f.write('<th><a href="http://zimonet.vivisimo.com/vivisimo/cgi-bin/query-meta?v:project=zimonet-bugzilla&v:sources=bugzilla&query=%s">&#9072; Bugzilla</a></th>' % my_results.first.name)
  f.write('<th><a href="#bottom">&darr; Bottom &darr;</a></th>')
  f.write('<th align="right"><a href="%s.html">&rarr; %s &rarr;</a></th>' %
          ([next_name]*2)) if next_name
  f.write('</tr></table></a>')

  passed = my_results.select {|r| r.passed}
  targets = Set.new(passed.map {|r| r.target}).sort
  f.write('<p>Overall pass rate for <b>%s</b> is %.1f%%' %
          [my_results.first.name, 100.0*passed.length/my_results.length])
  f.write(' (%d passed out of %d runs).</p>' %
          [passed.length, my_results.length])

  f.write("\n" + '<table id="history" class="tablesorter" summary="%s">' %
          summary)
  f.write('<thead>' +
          '<tr><th>Result&nbsp;&nbsp;&nbsp;&nbsp;</th>' +
          '<th>Start&nbsp;&nbsp;&nbsp;&nbsp;</th>' +
          '<th>Elapsed&nbsp;&nbsp;&nbsp;&nbsp;</th>' +
          '<th>Target&nbsp;&nbsp;&nbsp;&nbsp;</th>' +
          '<th>Run&nbsp;&nbsp;&nbsp;&nbsp;</th>' +
          '<th>Run Pass %&nbsp;&nbsp;&nbsp;&nbsp;</th></tr>' +
          "</thead><tbody>\n")
  my_results.each {|r|
    percent_pass = 100*trr.fraction_pass(r.target, r.run)
    color = r.passed ? 'lightgreen' : (percent_pass >= 50 ? 'pink' : 'yellow')
    style = 'background-color: %s' % color
    if r.passed
      pass_fail = 'Pass'
    else
      link = 'http://testbed10.test.vivisimo.com%s' % r.loc[/\/testrun\/.*/]
      # There is a fuzzy line when we do the switch to testbed14 ...
      # What a hack!
      if (r.run[0..2] == '7.0' and r.run >= '7.0-8') \
        or (r.run[0..2] == '7.5' and r.run >= '7.5-6-rc11') \
        or r.run[0..10] == '7.5-6-patch' \
        or (r.run == '7.5-6-rc10' and r.target == 'solaris_64_s') \
        or (r.run[0..0] == '8' and not r.run[0..15] == '8.0-beta0-build1') \
        or r.run[0..0] > '8'
        link = 'http://testbed14.test.vivisimo.com%s' % r.loc
      end
      # FIXME: check if the link is good before publishing it
      # Following links could avoid the insane "if" above...
      pass_fail = ('<a href="%s">Fail</a>' % link)
    end
    f.write('<tr>')
    td(f, style, pass_fail)
    td(f, style, r.start.strftime('%Y-%m-%d %H:%M'))
    td(f, style + '; text-align: right', '%s' %
       format_seconds(r.finish - r.start))
    td(f, style, r.target)
    td(f, style, r.run)
    td(f, style + '; text-align: right', '%.0f%%' % percent_pass)
    f.write("</tr>\n")
  }
  f.write("</tbody></table>\n")

  unless passed.empty?
    first_time = (1000*passed.first.start.to_f).to_i
    last_time = (1000*passed.last.start.to_f).to_i

    max_elapsed = passed.map {|r| r.finish-r.start}.max
    # Maybe adjust the units for the Y axis, based on the data.
    y_label = 'seconds'
    y_factor = 1
    if max_elapsed > 7200     # two hours
      y_factor = 3600.0
      y_label = 'hours'
    elsif max_elapsed > 120   # two minutes
      y_factor = 60.0
      y_label = 'minutes'
    end
    f.write('<h2>Run Times for each Pass for %s</h2>' %
            my_results.first.name)
    f.write('<div id="run-times" style="width:800px;height:400px;"></div>')
    f.write("#{y_label}")

    f.write('<script language="javascript" type="text/javascript">
  $(function () {')
    targets.each {|t|
      this_target = passed.select {|r| r.target == t}
      xy = this_target.map {|r| [(1000*r.start.to_f).to_i,
                                 (r.finish-r.start)/y_factor]}
      max_elapsed = xy.map {|x,y| y}.max
      f.write("\n var %s=%s;" % [t, xy.inspect])
    }
    f.write('
 $.plot($("#run-times"), [%s],
        { legend:{position:"nw"}, xaxis:{mode:"time"} } ); });
</script>
' % [targets.map{|t| '{data:%s,label:"%s"}'%[t,t]}.join(',')])
  end
  f.write('<br/><a name="bottom"><table width="100%"><tr>')
  f.write('<th align="left"><a href="%s.html#bottom">&larr; %s &larr;</a></th>' %
          ([prev_name]*2)) if prev_name
  f.write('<th><a href="#top">&uarr; Top &uarr;</a></th>')
  f.write('<th align="right"><a href="%s.html#bottom">&rarr; %s &rarr;</a></th>' %
          ([next_name]*2)) if next_name
  f.write('</tr></table></a>')
  f.write("</body></html>\n")
end

def td(f, style, text)
  f.write('<td style="%s">%s</td>' % [style, text])
end

def format_seconds(arg)
  seconds = arg.to_i
  # if seconds >= 3600
  #   '%d:%02d:%02d' % [seconds/3600, seconds/60%60, seconds%60]
  # elsif seconds >= 60
  #   ':%02d:%02d' % [seconds/60, seconds%60]
  # else
  #   '::%02d' % [seconds%60]
  # end
  '%d:%02d:%02d' % [seconds/3600, seconds/60%60, seconds%60]
end

if __FILE__ == $0
  trr = TestRunResults.new()    # Takes well over a minute...
  puts 'parse complete'
  sorted_results = trr.flat_results # Takes several seconds...
  puts "sorted list #{sorted_results.length}"
  names = Set.new(sorted_results.map {|r| r.name}).sort
  puts "#{names.length} unique test names"
  index = File.open('index.new', 'w')
  index.write(HTML_START % (['Test Run History',
                             '[0,0]',
                             'Test Run History']))
  index.write('<table id="history" class="tablesorter" summary="Test Run History"><thead>' +
          '<tr><th>Test&nbsp;&nbsp;&nbsp;&nbsp;</th>' +
          '<th>Run<br/>Count&nbsp;&nbsp;&nbsp;&nbsp;</th>' +
          '<th>Pass %&nbsp;&nbsp;&nbsp;&nbsp;</th>' +
          '<th>First Run&nbsp;&nbsp;&nbsp;&nbsp;</th>' +
          '<th>Last Run&nbsp;&nbsp;&nbsp;&nbsp;</th>' +
          '<th>Minimum&nbsp;&nbsp;&nbsp;&nbsp;<br/>Run Time&nbsp;&nbsp;&nbsp;&nbsp;</th>' +
          '<th>Average&nbsp;&nbsp;&nbsp;&nbsp;<br/>Run Time&nbsp;&nbsp;&nbsp;&nbsp;</th>' +
          '<th>Maximum&nbsp;&nbsp;&nbsp;&nbsp;<br/>Run Time&nbsp;&nbsp;&nbsp;&nbsp;</th></tr>' +
          "</thead><tbody>\n")
  names.length.times {|j|
    n = names[j]
    test_results = sorted_results.select {|r| r.name==n}
    passed = test_results.count {|r| r.passed}
    run_times = test_results.map {|r| (r.finish-r.start).to_i}
    total_run = run_times.reduce {|x,y| x += y}
    average_run = total_run.to_f/run_times.length
    index.write('<tr>')
    index.write('<td><a href="%s.html">%s</a></td>' % ([n]*2))
    index.write('<td>%d</td>' % test_results.length)
    index.write('<td>%.1f%%</td>' %
                (100.0*passed/test_results.length))
    index.write('<td>%s</td>' %
                test_results.first.start.strftime('%Y-%m-%d %H:%M'))
    index.write('<td>%s</td>' %
                test_results.last.start.strftime('%Y-%m-%d %H:%M'))
    index.write('<td style="text-align: right">%s</td>' %
                format_seconds(run_times.min))
    index.write('<td style="text-align: right">%s</td>' %
                format_seconds(average_run))
    index.write('<td style="text-align: right">%s</td>' %
                format_seconds(run_times.max))
    index.write("</tr>\n")
    File.open("%s.html" % n, 'w') {|f|
      test_page(f, test_results, trr,
                names[(j-1)%names.length], names[(j+1)%names.length])
    }
  }
  index.write("</tbody></table></body></html>\n")
  index.close
  FileUtils.mv('index.new', 'index.html')
end
