module FacebookPagesHelper

  def like_count_label(page)
    "#{page.likes.to_i} Likes"
  end

  def talking_about_count_label(page)
    "#{page.talking_about_count.to_i} Talking About"
  end

  def like_graph_values(page)
    Graph::FacebookPageGraph.new(page).simple_likes.join(',') rescue ''
  end

  def talking_about_graph_values(page)
    Graph::FacebookPageGraph.new(page).simple_talking_about_count.join(',') rescue ''
  end
end
