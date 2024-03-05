def get_audit_log(c, hash, results)
  end_of_wait = Time.now + 10
  entries = nil
  token = nil

  while ((! entries or entries.length == 0) and Time.now <= end_of_wait) do
    sleep 1
    audit_log = c.audit_log_retrieve
    entries = audit_log.xpath('/audit-log-retrieve-response/audit-log-entry')
    token = audit_log.xpath('/audit-log-retrieve-response/@token').first.to_s
  end

  if token and ! token.empty?
    c.audit_log_purge(token)
  end

  hash.input_log_entries(entries)
end
