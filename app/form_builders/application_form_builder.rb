class ApplicationFormBuilder < ActionView::Helpers::FormBuilder
  include React::Rails::ViewHelper

  def phone_number_field(method, opts = {})
    default_opts = {
      name: "#{@object_name}[#{method}]",
      method: method,
      value: @object.respond_to?(method) ? @object.send(method) : nil,
      errors: @object.errors.to_hash.fetch(method, nil)
    }
    props = default_opts.merge(opts)

    prerender_component("PhoneNumberField", props)
  end

  def date_picker(method, opts = {})
    default_opts = {
      name: "#{@object_name}[#{method}]",
      method: method,
      value: @object.respond_to?(method) ? @object.send(method) : nil,
      errors: @object.errors.to_hash.fetch(method, nil)
    }
    props = default_opts.merge(opts)

    prerender_component("DatePickerField", props, prerender: false)
  end

  def prerender_component(name, props, prerender: true)
    react_component(name, props, {prerender: prerender})
  end
end
