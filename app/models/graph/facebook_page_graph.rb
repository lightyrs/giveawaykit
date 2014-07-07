class Graph::FacebookPageGraph < Graph

  def initialize(page)
    return unless @page = page
  end

  def likes
    generate_graph_data :likes
  end

  def simple_likes
    generate_graph_data :likes, simple: true
  end

  def talking_about_count
    generate_graph_data :talking_about_count
  end

  def simple_talking_about_count
    generate_graph_data :talking_about_count, simple: true
  end

  private

  def generate_graph_data(key, options = {})
    return [] unless key.is_a? Symbol
    graphable_audits.map do |audit|
      if audit.is.has_key?(key) && options[:simple]
        simple_format_audit(audit, audit.is[key])
      elsif audit.has_key?(key)
        format_audit(audit, audit.is[key])
      end
    end.compact
  end

  def graphable_audits
    @graphable_audits ||= @page.audits.where("created_at >= ? AND created_at <= ?", 1.week.ago, Time.now).group_by do |audit|
      audit.created_at.day
    end.map { |day, audits| audits.last }
  rescue => e
    []
  end
end
