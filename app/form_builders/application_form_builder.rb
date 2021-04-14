class ApplicationFormBuilder < ActionView::Helpers::FormBuilder
  include React::Rails::ViewHelper

  def phone_number_field(method, opts = {})
    default_opts = {className: "mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-300 focus:ring focus:ring-indigo-200 focus:ring-opacity-50 #{"border-2 border-red-500" if @object.errors.any?}"}
    props = {
      name: "#{@object_name}[#{method}]",
      method: method,
      value: @object.respond_to?(method) ? @object.send(method) : nil,
      errors: @object.errors.to_hash.fetch(method, nil)
    }
    merged_opts = default_opts.merge(opts).merge(props)

    prerender_component("PhoneNumberField", merged_opts)
  end

  def prerender_component(name, props)
    react_component(name, props, {prerender: true})
  end
end
