class TagViewHooks < FatFreeCRM::Callback::Base

  def tags_field
<<EOS
- asset = params[:controller].singularize
- # Build asset tags manually in case the asset validation failed.
- if params[asset] && params[asset][:tag_list]
  - f.object.tags = params[asset][:tag_list].split(",").map {|x| ActsAsTaggableOn::Tag.find_by_name(x.strip)}.compact.uniq
%tr
  %td{ :valign => :top, :colspan => span }
    .label.req Tags: <small>(comma separated, letters and digits only)</small>
    %dd#facebook-list
      = f.text_field :tag_list, :id => "tag_list", :style => "width:500px", :autocomplete => "off"
      #facebook-auto
        .default Type the name of a tag you'd like to use.  Use commas to separate multiple tags.
        %ul.feed
          - # Get tags from either the unsaved params, or from the object.
          - tags = (params[asset] && params[asset][:tag_list]) ? params[asset][:tag_list].split(",") : f.object.tags.map{|t| t.name }
          - tags.each do |tag|
            %li{ :value => tag }= tag
        :javascript
          fbtaglist = new FacebookList('tag_list', 'facebook-auto',
                                      { newValues: true,
                                        regexSearch: false,
                                        separator: Event.KEY_COMMA });
          var tagjson = #{ActsAsTaggableOn::Tag.all.map{|t| {"caption" => t.name, "value" => t.name} }.to_json}
          tagjson.each(function(t){fbtaglist.autoFeed(t)});
EOS
end

  #----------------------------------------------------------------------------
  def javascript_includes(view, context = {})
    includes = ""
    # Load facebooklist.js for tag input
    includes << view.javascript_include_tag("/plugin_assets/crm_tags/javascripts/facebooklist.js")
    # No reason we cant put a stylesheet here too...
    includes << view.stylesheet_link_tag("/plugin_assets/crm_tags/stylesheets/facebooklist.css")
    includes
  end

  def tags_for_index
<<EOS
%dt
  .tags= tags_for_index(model)
end
EOS
  end

  def tags_for_show
<<EOS
.tags(style="margin:4px 0px 4px 0px")= tags_for_show(model)
EOS
  end
  
  def tags_styles
<<EOS
.tags, .list li dt .tags
  a:link, a:visited
    :background lightsteelblue
    :color white
    :font-weight normal
    :padding 0px 6px 1px 6px
    :-moz-border-radius 8px
    :-webkit-border-radius 8px
  a:hover
    :background steelblue
    :color yellow
EOS
end

  def tags_javascript
<<EOS
crm.search_tagged = function(query, controller) {
  if ($('query')) {
    $('query').value = query;
  }
  crm.search(query, controller);
}
// Assign var fbtaglist, so we can acess it throughout the DOM.
var fbtaglist = null;
EOS
  end
  
  #----------------------------------------------------------------------------
  def inline_styles(view, context = {})
    Sass::Engine.new(tags_styles).render
  end

  #----------------------------------------------------------------------------
  def javascript_epilogue(view, context = {})
    tags_javascript
  end

  #----------------------------------------------------------------------------
  [ :account, :campaign, :contact, :lead, :opportunity ].each do |model|

    define_method :"#{model}_top_section_bottom" do |view, context|
      Haml::Engine.new(tags_field).render(view, :f => context[:f], :span => (model != :campaign ? 3 : 5))
    end

    define_method :"#{model}_bottom" do |view, context|
      unless context[model].tag_list.empty?
        Haml::Engine.new(tags_for_index).render(view, :model => context[model])
      end
    end

    define_method :"show_#{model}_sidebar_bottom" do |view, context|
      unless context[model].tag_list.empty?
        Haml::Engine.new(tags_for_show).render(view, :model => context[model])
      end
    end

  end

end

