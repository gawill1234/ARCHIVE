#!/usr/bin/env ruby

require "mysql2"
GAUGEDB = Mysql2::Client.new(:database => 'gauge',
                             :host => 'eng-db.vivisimo.com',
                             :password => 'aTZp6wmymVcsuCmz',
                             :sslkey => '/dev/null',
                             :username => 'gauge')

GET_ID_COMMENT = "select ID, TestName, RunVersion, RunTarget, Result, Notes" +
  " from tblTestRunDetails where LogFilePath='%s'"
GET_BUGS = "select BugNumber from tblTestDetailBugs where TestDetailID=%s"
SET_COMMENT = "update tblTestRunDetails set notes='%s' where id=%s"
ADD_BUG = "insert into tblTestDetailBugs set TestDetailID=%s, BugNumber=%s"

# The mysql2 package doesn't return a Ruby array.
def result_list(res)
  res.map{|item| item}
end

def add_comment(log_file_path, comment, options)
  bug = options[:bug]
  res = result_list(GAUGEDB.query(GET_ID_COMMENT % [GAUGEDB.escape(log_file_path)]))
  # Demand a single match
  raise 'No detail record found for %s' % log_file_path if res.count == 0
  raise 'Multiple detail records found for %s' % log_file_path if res.count > 1
  id, test_name, version, target, result, old_comment =
    res.first.values_at('ID', 'TestName', 'RunVersion', 'RunTarget', 'Result', 'Notes')
  bug_list = result_list(GAUGEDB.query(GET_BUGS % [id])).map{|row| row['BugNumber']}
  if bug_list == [bug] and old_comment == comment
    puts 'Bug %s and matching comment already in place for id=%d' % [bug, id] if
      options[:verbose]
  else
    puts 'Existing bugs: %s' % bug_list.inspect unless bug_list == []
    puts 'Old comment: %s' % old_comment.inspect unless
      old_comment == '' or old_comment == 'None'
    if options[:replace] or old_comment == '' or old_comment == 'None'
      puts "Adding note to %s which %s for Velocity %s on %s.\nbug %s: %s\n" %
        [test_name, result, version, target, bug.inspect, comment.inspect]
      GAUGEDB.query(SET_COMMENT % [GAUGEDB.escape(comment), id])
      GAUGEDB.query(ADD_BUG % [id, bug]) if bug and not bug_list.include?(bug)
    else
      puts 'Not modifying existing comment for %s' % log_file_path
    end
  end
end

if __FILE__ == $0
  require 'trollop'
  opts = Trollop::options do
    opt(:log_file_paths, 'List of log file directory paths',
        type: :strings, required: true)
    opt(:comment, 'Comment for this test run', type: :string, required: true)
    opt(:bug_number, 'Bugzilla bug number (optional)', type: :int)
    opt(:replace, 'Replace existing comment')
  end
  opts[:log_file_paths].each {|path|
    begin
      add_comment(path, opts[:comment],
                  bug: opts[:bug_number], replace: opts[:replace])
    rescue => ex
      puts ex
    end
  }
end
