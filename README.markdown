Tags plugin for Fat Free CRM
============================

The Tags adds tagging support to all major Fat Free CRM models. To search by tag enter its
name prefixed by # character. For example:

    Search: hello #world

In this example "hello" is regular search string, and "world" is a tag.


Installation
============

1) The Tags plugin depends on the [acts-as-taggable-on](github.com/mbleigh/acts-as-taggable-on)
   gem. Add this line to the bottom of your Gemfile:

    gem 'acts-as-taggable-on', '>= 2.0.6'

   Then run `bundle install`


2) Install the tags plugin:

    rails plugin install git://github.com/crossroads/tags.git


4) Run the plugin migrations:

    rake db:migrate:plugins


5) Restart your web server.

