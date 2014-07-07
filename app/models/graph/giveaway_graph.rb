class Graph::GiveawayGraph < Graph

  def initialize(giveaway)
    return unless @giveaway = giveaway
  end

  def page_likes
    generate_graph_data :_page_likes
  end

  def net_likes
    generate_graph_data :_page_likes_while_active
  end

  def shares
    generate_graph_data :_total_shares
  end

  def entries
    generate_graph_data :_entry_count
  end

  def views
    generate_graph_data :_views
  end

  private

  def generate_graph_data(key)
    return [] unless key.is_a? Symbol
    graphable_audits.map do |audit|
      if audit.is.has_key?(:analytics)
        format_audit(audit, audit.is[:analytics][key])
      end
    end.compact
  end

  def graphable_audits
    @graphable_audits ||= @giveaway.audits.where("created_at >= ? AND created_at <= ?", @giveaway.start_date, (@giveaway.end_date || Time.now))
  rescue => e
    []
  end
end
