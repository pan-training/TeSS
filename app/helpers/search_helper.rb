# The helper for searches
module SearchHelper

  def search_and_facet_params
    params.permit(*@model.search_and_facet_keys)
  end

  def clear_filters_path
    params.to_unsafe_h.except(*@model.search_and_facet_keys, :page)
  end

  def facet_title(name, value, html_options = {})
    lang = render_language_name(value) if name.to_s == 'language'
    return lang unless lang.blank?

    html_options.delete(:title) || truncate(value.to_s, length: 50)
  end

  def filter_link(name, value, count, html_options = {}, &block)
    parameters = build_filter_parameters(name, value, html_options)
    html_options.reverse_merge!(title: value.to_s)

    link_to parameters, html_options do
      if block_given?
        block.call
      else
        content_tag(:span, facet_title(name, value, html_options), class: 'facet-label') +
          content_tag(:span, "#{count}", class: 'facet-count')
      end
    end
  end

  def filter_form(name, value, count, html_options = {}, &block)
    parameters = build_filter_parameters(name, value, html_options)
    button_options = html_options.dup
    button_options[:class] = [button_options[:class], 'facet-option-button'].compact.join(' ')
    button_options.reverse_merge!(title: value.to_s, type: 'submit')

    form_tag(polymorphic_path(@model), method: :get, enforce_utf8: false, class: 'facet-option-form') do
      safe_join(facet_param_hidden_fields(parameters) + [
        button_tag(button_options) do
          if block_given?
            block.call
          else
            content_tag(:span, facet_title(name, value, button_options), class: 'facet-label') +
              content_tag(:span, count.to_s, class: 'facet-count')
          end
        end
      ])
    end
  end

  def remove_filter_link(name, value, html_options = {}, &block)
    parameters = search_and_facet_params

    #delete a filter from an array or delete the whole facet if it is the only one
    if parameters.include?(name)
      if parameters[name].is_a?(Array)
        parameters[name].delete(value)
        # Go back to being just a singleton if only one element left
        parameters[name] = parameters[name].first if parameters[name].one?
      else
        parameters.delete(name)
      end
    end

    parameters.delete('page') #remove the page option if it exists
    html_options.reverse_merge!(title: value.to_s)

    link_to parameters, html_options do
      if block_given?
        block.call
      else
        content_tag(:span, facet_title(name, value, html_options), class: 'facet-label') +
          content_tag(:i, '', class: 'remove-facet-icon glyphicon glyphicon-remove')
      end
    end
  end

  def toggle_hidden_facet_link facet
    return "<span class='toggle-#{facet}' style='font-weight: bold;'>
            Show more #{facet.humanize.pluralize.downcase}</span>
            <i class='glyphicon glyphicon-chevron-down pull-right toggle-#{facet}'></i>
            <span class='toggle-#{facet}' style='font-weight: bold; display: none;'>
            Show fewer #{facet.humanize.pluralize.downcase}</span>
            <i class='glyphicon glyphicon-chevron-up pull-right toggle-#{facet}' style='display: none;'></i>
            ".html_safe
  end

  private

  def build_filter_parameters(name, value, html_options = {})
    parameters = search_and_facet_params.to_h
    key = name.to_s

    # if there's already a filter of the same facet type, create/add to an array
    if parameters.include?(key) && !html_options.delete(:replace)
      parameters[key] = Array.wrap(parameters[key]) | [value]
    else
      parameters[key] = value
    end

    parameters.delete('page') # remove the page option if it exists
    parameters.delete(:page)
    parameters
  end

  def facet_param_hidden_fields(parameters)
    parameters.flat_map do |key, value|
      if value.is_a?(Array)
        value.map { |item| hidden_field_tag("#{key}[]", item) }
      else
        [hidden_field_tag(key, value)]
      end
    end
  end
end
