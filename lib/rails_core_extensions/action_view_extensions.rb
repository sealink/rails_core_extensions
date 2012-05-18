module ActionViewExtensions
  
  def self.included(base)
    base.send :include, InstanceMethods
  end
  
  module InstanceMethods
    
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
        haml_tag 'div', :id => 'others', :style => 'display: none' do
          others.each do |o|
            yield o
          end
        end
        "#{others.size} Others - ".html_safe + link_to_function("Show/Hide", "$('others').toggle()")
      end
    end
    
    
    def calculate_nested_array
      namespaces + [current_object]
    end
  
    
    def breadcrumbs(object_or_nested_array = calculate_nested_array, path = objects_path, options = {})
      object = object_or_nested_array.is_a?(Array) ? object_or_nested_array.last : object_or_nested_array

      link_to(object.class.table_name.titleize, path) + ': ' + if object.new_record?
        'New'
      else
        if options[:index]
          (object.respond_to?(:name) ? object.name : object.to_s)
        else
          text = object.respond_to?(:name) && !object.name.blank? ? object.name : object.to_s
          if controller.respond_to?(:show) && params[:action] == 'edit'
            link_to text, objects_path
          else
            text
          end.to_s + (params[:action] == 'edit' ? ': Edit' : '')
        end
      end
    end
  
  end
end
ActionView::Base.send(:include, ActionViewExtensions) if defined?(ActionView::Base)