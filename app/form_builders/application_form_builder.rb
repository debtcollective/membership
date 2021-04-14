class ApplicationFormBuilder < ActionView::Helpers::FormBuilder
  def phone_number_field(method, opts = {})
    default_opts = {className: "mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-300 focus:ring focus:ring-indigo-200 focus:ring-opacity-50 #{"border-2 border-red-500" if @object.errors.any?}"}
    merged_opts = default_opts.merge(opts)

    react_component("PhoneNumberField", props: merged_opts)
  end
end
