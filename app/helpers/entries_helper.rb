module EntriesHelper

  include ActionView::Helpers::UrlHelper

  def entry_name(entry)
    if entry.name.present?
      link_to entry.name, entry.fb_url, target: '_blank'
    else
      ''
    end
  end

  def entry_unix_timestamp(entry)
    entry.created_at.to_i
  end
end
