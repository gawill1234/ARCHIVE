# PRINT_AUDIT_LOG_IN_ANY_CASE: keep at "false", switch to "true"
#   when troubleshooting
PRINT_AUDIT_LOG_IN_ANY_CASE = false

# Local
def count_entries_with_given_status_in_audit_log(audit_log, status)
  audit_log_entries = audit_log.
      xpath('/audit-log-retrieve-response/audit-log-entry')
  matching_audit_log_entries =
      audit_log_entries.select {|e| e['status'] =~ /^#{status}/}
  matching_audit_log_entries.length
end

# Method check_and_purge_audit_log:
# Retrieves audit log, counts entries with status "status",
# pass/fail whether it's expected number, purges, conditionally prints and
# returns audit_log

def check_and_purge_audit_log(collection, results, status, expected)
  # If we are not finding expected entries in audit log,
  # give them a chance to appear - wait and retry.
  retry_until = Time.now + 90
  begin
    sleep 1
    audit_log = collection.audit_log_retrieve
    number_of_matching_entries =
      count_entries_with_given_status_in_audit_log(audit_log,
        status)
  end while ((number_of_matching_entries != expected) &&
       Time.now <= retry_until)

  results.add(number_of_matching_entries == expected,
    "Found #{number_of_matching_entries} entries with "\
       "status #{status} in audit log on #{collection.name}.",
    "Found #{number_of_matching_entries} entries with "\
       "status #{status} in audit log on #{collection.name}, "\
       "expected #{expected}.")

  audit_token = audit_log.
      xpath('/audit-log-retrieve-response/@token').first.to_s

  if ! audit_token.empty?
    collection.audit_log_purge(audit_token)
  end

  if (number_of_matching_entries != expected) || PRINT_AUDIT_LOG_IN_ANY_CASE
    msg "* Retrieved from audit log: *"
    msg "#{audit_log}"
    msg "* ------------------------- *"
  end

  audit_log
end

# Local
def count_deletes_with_given_state_in_audit_log(audit_log, state, sub)
  deletes_path = '/audit-log-retrieve-response/audit-log-entry/crawl-delete'
  if sub
    deletes_path += '/crawl-delete'
  end
  deletes = audit_log.xpath(deletes_path)
  matching_deletes =
      deletes.select {|e| e['state'] =~ /^#{state}/}
  matching_deletes.length
end

# Method check_audit_log_vse_key_deletes:
# Retrieves audit log, counts crawl-delete entries (sub==false) or
# sub-entries (sub==true) with status "status",
# pass/fail whether it's expected number,
# and conditionally prints audit_log

def check_audit_log_vse_key_deletes(collection, results, state, expected,
                                    sub=true)
  # If we are not finding expected (sub-)entries in audit log,
  # give them a chance to appear - wait and retry.
  retry_until = Time.now + 90
  begin
    sleep 1
    audit_log = collection.audit_log_retrieve
    number_of_matching_deletes =
      count_deletes_with_given_state_in_audit_log(audit_log,
        state, sub)
  end while ((number_of_matching_deletes != expected) &&
       Time.now <= retry_until)

  sub_message = (sub ? "sub-" : "")
  results.add(number_of_matching_deletes == expected,
    "Found #{number_of_matching_deletes} delete #{sub_message}entries with "\
       "state #{state} in audit log on #{collection.name}.",
    "Found #{number_of_matching_deletes} delete #{sub_message}entries with "\
       "state #{state} in audit log on #{collection.name}, "\
       "expected #{expected}.")

  if (number_of_matching_deletes != expected) ||
        PRINT_AUDIT_LOG_IN_ANY_CASE
    msg "* Retrieved from audit log: *"
    msg "#{audit_log}"
    msg "* ------------------------- *"
  end
end

# Method purge_audit_log:
# Primary purpose is to clear (with option to output)
# audit log prior to the test to avoid interference.

def purge_audit_log(collection)
  msg "Purging audit log on #{collection.name}"
  audit_log = collection.audit_log_retrieve
  audit_token = audit_log.
    xpath('/audit-log-retrieve-response/@token').first.to_s

  if ! audit_token.empty?
    collection.audit_log_purge(audit_token)
  end

  if PRINT_AUDIT_LOG_IN_ANY_CASE
    msg "* Retrieved from audit log: *"
    msg "#{audit_log}"
    msg "* ------------------------- *"
  end
end

# Method get_vertex_range_from_audit_log:
# Returns min and max of vertex values in the set of entries in audit_log
# Returns nils for min and max if there are no entries

def get_vertex_range_from_audit_log(audit_log)
  vertices = audit_log.
    xpath('/audit-log-retrieve-response/audit-log-entry/crawl-url/@vertex').to_a
  vertices.map!{|v| v.to_s.to_i}
  [vertices.min, vertices.max]
end

