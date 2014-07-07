class Graph

  private

  def simple_format_audit(audit, audit_attr)
    audit_attr.nil? ? 0 : audit_attr
  end

  def format_audit(audit, audit_attr)
    val = audit_attr.nil? ? 0 : audit_attr
    [js_timestamp(audit.created_at), val]
  end

  def js_timestamp(time)
    time.to_i * 1000
  end
end
