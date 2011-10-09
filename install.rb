# Install hook code here
puts "== Copying assets to public/"
`cp -r vendor/plugins/crm_tags/public/* public/`

puts <<-EOS
The Tags adds tagging support to all major Fat Free CRM models. To search by tag enter its
name prefixed by # character. For example:

  Search: hello #world

In this example "hello" is regular search string, and "world" is a tag.

The tags plugin depends on the acts-as-taggable-on gem.
Add this line to the bottom of your Gemfile:

    gem 'acts-as-taggable-on', '>= 2.0.6'


Then run `bundle install`

EOS

