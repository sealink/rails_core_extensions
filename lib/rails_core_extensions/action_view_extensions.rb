module RailsCoreExtensions
  module ActionViewExtensions
    def textilize(content)
      super(h(content)).html_safe
    end

    # Will recursively parse a Hash and any sub hashes to be normal hashes
    # This is useful when exporting hashes to non ruby systems, which don't understand HashWithIndifferentAccess
    def hashify(element)
      if element.is_a? Hash
        element = element.to_hash if element.is_a?(HashWithIndifferentAccess)
        element.each_pair do |key, value|
          element[key] = hashify(value)
        end
      else
        # Must hashify enumerables encase their sub items are hashes
        # Can't enumerate through string as it returns strings, which are also enumerable (stack level too deep)
        if element.respond_to?(:each) && !element.is_a?(String)
          element.map{ |sub| hashify(sub) }
        else
          element
        end
      end
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

    def expandable_list_for(objects, show = 4)
      first, others = objects[0..(show-1)], objects[show..(objects.size-1)]
      first.each do |o|
        yield o
      end
      if others
        content_tag 'div', :id => 'others', :style => 'display: none' do
          others.each do |o|
            yield o
          end
        end
        "#{others.size} Others - ".html_safe + link_to_function("Show/Hide", "$('others').toggle()")
      end
    end

    def boolean_select_tag(name, *args)
      options = args.extract_options!
      options ||= {}
      opts = [['Yes', '1'], ['No', '0']]
      select_tag name, options_for_select(opts, options[:selected]), options.except(:selected)
    end
  end
end

ActionView::Base.send(:include, RailsCoreExtensions::ActionViewExtensions) if defined?(ActionView::Base)
