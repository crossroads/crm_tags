Tags plugin for Fat Free CRM
============================

The Tags adds tagging support to all major Fat Free CRM models. To search by tag enter its
name prefixed by # character. For example:

    Search: hello #world

In this example "hello" is regular search string, and "world" is a tag.


Installation
============

1) The Tags plugin depends on the [acts-as-taggable-on](github.com/mbleigh/acts-as-taggable-on)
   plugin which must be installed as follows:

    rails plugin install git://github.com/mbleigh/acts-as-taggable-on.git
    rails generate acts_as_taggable_on_migration
    rake db:migrate

2) Install the tags plugin:

    rails plugin install git://github.com/crossroads/tags.git

3) Run the plugin migrations:

    rake db:migrate:plugins

4) Restart your web server.

