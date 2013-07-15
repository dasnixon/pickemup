module ApplicationHelper
  def link_to_self(name = nil, options = nil, html_options = nil, &block)
    html_options ||= {}
    html_options.merge!(target: '_self')
    html_options, options = options, name if block_given?
    options ||= {}

    html_options = convert_options_to_data_attributes(options, html_options)

    url = url_for(options)
    html_options['href'] ||= url

    content_tag(:a, name || url, html_options, &block)
  end
end
