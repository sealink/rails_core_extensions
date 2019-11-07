module RailsCoreExtensions
  module ActionViewExtensions
    def textilize(content)
      super(h(content)).html_safe
    end

    # Generates a tooltip with given text
    # text is textilized before display
    def tooltip(hover_element_id, text, title='')
      content = "<div style='width: 25em'>#{textilize(text)}</div>"
      "<script>" +
        "new Tip('#{hover_element_id}', '#{escape_javascript(content)}',"+
        "{title : '#{escape_javascript title}', className: 'silver_smaller_div',"+
        "showOn: 'mouseover', hideOn: { event: 'mouseout' }, fixed: false});"+
      "</script>"
    end

    def boolean_select_tag(name, *args)
      options = args.extract_options!
      options ||= {}
      yes_no_opts = [%w[Yes 1], %w[No 0]]
      option_tags = options_for_select(yes_no_opts, options[:selected])
      select_tag name, option_tags, options.except(:selected)
    end
  end
end
