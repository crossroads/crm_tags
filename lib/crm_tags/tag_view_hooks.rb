class TagViewHooks < FatFreeCRM::Callback::Base

  def tags_for_index
<<EOS
%dt
  .tags= tags_for_index(model)
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

/* Override the 'hide_form' function, to remove any duplicate 'facebook-list' elements
   before running the 'BlindUp' effect. (The disappearing facebook-list takes precedence over
   the newly created facebook-list that is being AJAX loaded, and messes up the initialization.. ) */
crm.hide_form = function(id) {
    if($('facebook-list')) $('facebook-list').remove();
    var arrow = $(id + "_arrow") || $("arrow");
    arrow.update(this.COLLAPSED);
    Effect.BlindUp(id, { duration: 0.25, afterFinish: function() { $(id).update("") } });
}
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
  def javascript_includes(view, context = {})
    # Load facebooklist.js for tag input (No reason we cant put the stylesheet here too...)
    includes =  view.javascript_include_tag("/plugin_assets/crm_tags/javascripts/facebooklist.js")
    includes << view.stylesheet_link_tag("/plugin_assets/crm_tags/stylesheets/facebooklist.css")
  end

  #----------------------------------------------------------------------------
  [ :account, :campaign, :contact, :lead, :opportunity ].each do |model|

    define_method :"#{model}_top_section_bottom" do |view, context|
      view.render :partial => "/common/tags", :locals => {:f => context[:f], :span => (model != :campaign ? 3 : 5)}
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

