class TagViewHooks < FatFreeCRM::Callback::Base

  ActsAsTaggableOn::Tag.all

  TAGS_FIELD = <<EOS
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

  #----------------------------------------------------------------------------
  def javascript_includes(view, context = {})
    includes = ""
    # Load facebooklist.js for tag input
    includes << view.javascript_include_tag("/plugin_assets/crm_tags/javascripts/facebooklist.js")
    # No reason we cant put a stylesheet here too...
    includes << view.stylesheet_link_tag("/plugin_assets/crm_tags/stylesheets/facebooklist.css")
    includes
  end

  TAGS_FOR_INDEX = <<EOS
%dt
  .tags= tags_for_index(model)
EOS

  TAGS_FOR_SHOW = <<EOS
.tags(style="margin:4px 0px 4px 0px")= tags_for_show(model)
EOS

  TAGS_STYLES = <<EOS
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

  TAGS_JAVASCRIPT = <<EOS
crm.search_tagged = function(query, controller) {
  if ($('query')) {
    $('query').value = query;
  }
  crm.search(query, controller);
}
// Assign var fbtaglist, so we can acess it throughout the DOM.
var fbtaglist = null;
EOS

  #----------------------------------------------------------------------------
  def inline_styles(view, context = {})
    Sass::Engine.new(TAGS_STYLES).render
  end

  #----------------------------------------------------------------------------
  def javascript_epilogue(view, context = {})
    TAGS_JAVASCRIPT
  end

  #----------------------------------------------------------------------------
  [ :account, :campaign, :contact, :lead, :opportunity ].each do |model|

    define_method :"#{model}_top_section_bottom" do |view, context|
      Haml::Engine.new(TAGS_FIELD).render(view, :f => context[:f], :span => (model != :campaign ? 3 : 5))
    end

    define_method :"#{model}_bottom" do |view, context|
      unless context[model].tag_list.empty?
        Haml::Engine.new(TAGS_FOR_INDEX).render(view, :model => context[model])
      end
    end

    define_method :"show_#{model}_sidebar_bottom" do |view, context|
      unless context[model].tag_list.empty?
        Haml::Engine.new(TAGS_FOR_SHOW).render(view, :model => context[model])
      end
    end

  end

end

