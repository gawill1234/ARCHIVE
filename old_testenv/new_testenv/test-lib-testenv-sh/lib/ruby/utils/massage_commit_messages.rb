#!/usr/usr/bin/env ruby

commit_log = File.open('fixed-bugs-7.5-3rc7.txt', 'r')
bugs = Array.new
commit_log.each_line do |line|
  bugs << line.sub(/[0-9a-z]{40} /, '')
end

updated_log = File.open('sanitized-commits.txt', 'w')
bugs.sort!.uniq!.each do |bug|
  if bug.scan(/^[Bb]ug [0-9]+/).length > 0
    begin
      # TODO: scrape Bugzilla to see if bug is actually closed or not
      wiki_bug = '{{' + bug.scan(/^[Bb]ug [0-9]+/)[0].downcase.sub(' ', '|') + '}}'
      updated_log.write('* ' + wiki_bug + "\n")
    rescue
      puts 'exception: ' + bug
    end
  else
    puts 'No bug #: ' + bug
  end
end