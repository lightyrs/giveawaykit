module UiHelper

  def percentage_number(percentage_str)
    percentage_str.gsub("%", "")
  end

  def callout(options = {}, &block)
    type = options[:type] || 'info'

    haml_tag :div, class: "bs-callout bs-callout-#{type} #{options[:class]}" do
      haml_tag :h4, options[:title]
      if block
        block.call
      else
        haml_tag :p, options[:content]
      end
    end
  end

  def avatar(options = {})
    options[:class] ||= 'pull-left'

    if options[:link]
      linked_avatar(options)
    else
      unlinked_avatar(options)
    end
  end

  def linked_avatar(options = {})
    wrapper_class = options[:size] ? "avatar-wrapper-#{options[:size]}" : "avatar-wrapper"
    haml_tag :a, class: "#{options[:class]} #{wrapper_class}", href: "#{options[:link]}" do
      haml_tag :span, class: "thumb masked avatar", style: "background-image: url(#{options[:image_url]})"
    end
  end

  def unlinked_avatar(options = {})
    wrapper_class = options[:size] ? "avatar-wrapper-#{options[:size]}" : "avatar-wrapper"
    haml_tag :span, class: "#{options[:class]} #{wrapper_class}" do
      haml_tag :span, class: "thumb masked avatar", style: "background-image: url(#{options[:image_url]})"
    end
  end
end
