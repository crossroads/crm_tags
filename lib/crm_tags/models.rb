# Make all core models act as taggable.
#----------------------------------------------------------------------------
[ Account, Campaign, Contact, Lead, Opportunity ].each do |klass|
  klass.class_eval {
    acts_as_taggable_on :tags
    def tag(tag_name)
      if (tag_record = Tag.find_by_name(tag_name)) && tag_list.include?(tag_name);
        # Return tag with customfields if it exists, else create the tag table.
        if tag_obj = send(:"tag#{tag_record.id}")
          return tag_obj
        else
          return send(:"create_tag#{tag_record.id}")
        end
      end
      nil
    end
  }
end

