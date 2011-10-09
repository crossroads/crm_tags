# Install hook code here
puts <<-EOS
The Tags adds tagging support to all major Fat Free CRM models. To search by tag enter its
name prefixed by # character. For example:

  Search: hello #world

In this example "hello" is regular search string, and "world" is a tag.

The Tags plugin depends on the [acts-as-taggable-on] plugin which must be installed as follows:

    rails plugin install git://github.com/mbleigh/acts-as-taggable-on.git

EOS

