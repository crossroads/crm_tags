require "fat_free_crm"

FatFreeCRM::Plugin.register(:crm_sample_tabs, self) do
          name "Fat Free CRM Tags"
       authors "Michael Dvorkin, Jose Luis Gordo Romero"
       version "0.2"
   description "Adds tagging support to Fat Free CRM"
  dependencies :"acts-as-taggable-on", :haml
end

require "crm_tags"

Rails.configuration.middleware.insert_before ::Rack::Lock, ::ActionDispatch::Static, Rails.root.join('public')

