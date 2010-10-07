ApplicationHelper.module_eval do
  # Return asset tags to be built manually if the asset failed validation.
  def unsaved_param_tags(asset)
    params[asset][:tag_list].split(",").map {|x|
      ActsAsTaggableOn::Tag.find_by_name(x.strip)
    }.compact.uniq
  end
end
