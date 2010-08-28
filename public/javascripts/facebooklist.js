var FacebookList = Class.create(TextboxList, {
  initialize: function($super,element, autoholder, options, func) {
    $super(element, options);
    this.loptions = $H({
      autocomplete: {
        'opacity': 1,
        'maxresults': 10,
        'minchars': 1
      }
    });

    this.id_base = $(element).identify() + "_" + this.options.get("className");

    this.data = [];
    this.data_searchable = [];
    this.autoholder = $(autoholder).setOpacity(this.loptions.get('autocomplete').opacity);
    this.autoholder.observe('mouseover',function() {this.curOn = true;}.bind(this)).observe('mouseout',function() {this.curOn = false;}.bind(this));
    this.autoresults = this.autoholder.select('ul').first();
	  var children = this.autoresults.select('li');
    children.each(function(el) { this.add({value:el.readAttribute('value'),caption:el.innerHTML}); }, this);

    // Loading the options list only once at initialize.
    // This would need to be further extended if the list was exceptionally long
    if (!Object.isUndefined(this.options.get('fetchFile'))) {
      new Ajax.Request(this.options.get('fetchFile'), {
        method: this.options.get('fetchMethod'),
        onSuccess: function(transport) {
          transport.responseText.evalJSON(true).each(function(t) {
            this.autoFeed(t) }.bind(this));
          }.bind(this)
        }
      );
    }
  },

  autoShow: function(search) {
    this.autoholder.setStyle({'display': 'block'});
    this.autoholder.descendants().each(function(e) { e.hide() });
    if(! search || ! search.strip() || (! search.length || search.length < this.loptions.get('autocomplete').minchars)) {
      this.autoholder.select('.default').first().setStyle({'display': 'block'});
      this.resultsshown = false;
    } else {
      this.resultsshown = true;
      this.autoresults.setStyle({'display': 'block'}).update('');
      if (!this.options.get('regexSearch')) {
        var matches = new Array();
        if (search) {
          if (!this.options.get('caseSensitive')) {
            search = search.toLowerCase();
          }
          var matches_found = 0;
          for (var i=0,len=this.data_searchable.length; i<len; i++) {
            if (this.data_searchable[i].indexOf(search) >= 0) {
              matches[matches_found++] = this.data[i];
            }
          }
        }
      } else {
        if (this.options.get('wordMatch')) {
          var regexp = new RegExp("(^|\\s)"+search,(!this.options.get('caseSensitive') ? 'i' : ''));
        } else {
          var regexp = new RegExp(search,(!this.options.get('caseSensitive') ? 'i' : ''));
          var matches = this.data.filter(
            function(str) {
            return str ? regexp.test(str.evalJSON(true).caption) : false;
          });
        }
      }

      var count = 0;
      matches = matches.compact();
      matches = matches.sortBy(function(m) {
        m = m.evalJSON(true);
        return m.value.startsWith(search);
      }).reverse();
      matches.each(
        function(result, ti) {
          count++;
          if(ti >= (this.options.get('maxResults') ? this.options.get('maxResults') : this.loptions.get('autocomplete').maxresults)) return;
          var that = this;
          var el = new Element('li');
          el.observe('click',function(e) {
              e.stop();
              that.current_input = "";
              that.autoAdd(this);
            }
          ).observe('mouseover', function() { that.autoFocus(this); } ).update(
            this.autoHighlight(result.evalJSON(true).caption, search)
          );
          this.autoresults.insert(el);
          el.cacheData('result', result.evalJSON(true));
          if(ti == 0) this.autoFocus(el);
        },
        this
      );
    }
    if (count == 0) {
      // if there are no results, hide everything so that KEY_ENTER has no effect
      this.autoHide();
    } else {
      if (count > this.options.get('results'))
        this.autoresults.setStyle({'height': (this.options.get('results')*24)+'px'});
      else
        this.autoresults.setStyle({'height': (count?(count*24):0)+'px'});
    }

    return this;
  },

  autoHighlight: function(html, highlight) {
    return html.gsub(new RegExp(highlight,'i'), function(match) {
      return '<em>' + match[0] + '</em>';
    });
  },

  autoHide: function() {
    this.resultsshown = false;
    this.autoholder.hide();
    return this;
  },

  autoFocus: function(el) {
    if(! el) return;
    if(this.autocurrent) this.autocurrent.removeClassName('auto-focus');
    this.autocurrent = el.addClassName('auto-focus');
    return this;
  },

  autoMove: function(direction) {
    if(!this.resultsshown) return;
    this.autoFocus(this.autocurrent[(direction == 'up' ? 'previous' : 'next')]());
    this.autoresults.scrollTop = this.autocurrent.positionedOffset()[1]-this.autocurrent.getHeight();
    return this;
  },

  autoFeed: function(text) {
    var with_case = this.options.get('caseSensitive');
    if (this.data.indexOf(Object.toJSON(text)) == -1) {
      this.data.push(Object.toJSON(text));
      this.data_searchable.push(with_case ? Object.toJSON(text).evalJSON(true).caption : Object.toJSON(text).evalJSON(true).caption.toLowerCase());
    }
    return this;
  },

  autoAdd: function(el) {
    if(this.newvalue && this.options.get("newValues")) {
      this.add({caption: el.value, value: el.value, newValue: true});
      var input = el;
    } else if(!el || ! el.retrieveData('result')) {
      return;
    } else {
      this.add(el.retrieveData('result'));
      delete this.data[this.data.indexOf(Object.toJSON(el.retrieveData('result')))];
      var input = this.lastinput || this.current.retrieveData('input');
    }
    this.autoHide();
    input.clear().focus();
    return this;
  },

  createInput: function($super,options) {
    var li = $super(options);
    var input = li.retrieveData('input');
    input.observe('keydown', function(e) {
      this.dosearch = false;
      this.newvalue = false;

      switch(e.keyCode) {
        case Event.KEY_UP: e.stop(); return this.autoMove('up');
        case Event.KEY_DOWN: e.stop(); return this.autoMove('down');

        case Event.KEY_RETURN:
          // If the text input is blank and the user hits Enter call the
          // onEmptyInput callback.
          if (String('').valueOf() == String(this.current.retrieveData('input').getValue()).valueOf()) {
            this.options.get("onEmptyInput")();
          }
          e.stop();
          if(!this.autocurrent || !this.resultsshown) break;
          this.current_input = "";
          this.autoAdd(this.autocurrent);
          this.autocurrent = false;
          this.autoenter = true;
          break;
        case Event.KEY_ESC:
          this.autoHide();
          if(this.current && this.current.retrieveData('input'))
            this.current.retrieveData('input').clear();
          break;
        default:
          this.dosearch = true;
      }
    }.bind(this));
    input.observe('keyup',function(e) {
      var code = this.options.get('separator').code;
      var splitOn = this.options.get('separator').value;
      switch(e.keyCode) {
        case code:
          if(this.options.get('newValues')) {
            new_value_el = this.current.retrieveData('input');
            if (!new_value_el.value.endsWith('<')) {
              keep_input = "";
              if (new_value_el.value.indexOf(splitOn) < (new_value_el.value.length - splitOn.length)){
                separator_pos = new_value_el.value.indexOf(splitOn);
                keep_input = new_value_el.value.substr(separator_pos + 1);
                new_value_el.value = new_value_el.value.substr(0,separator_pos).escapeHTML().strip();
              } else {
                new_value_el.value = new_value_el.value.gsub(splitOn,"").escapeHTML().strip();
              }
              if(!this.options.get("spaceReplace").blank()) new_value_el.value.gsub(" ", this.options.get("spaceReplace"));
              if(!new_value_el.value.blank()) {
                e.stop();
                this.newvalue = true;
                this.current_input = keep_input.escapeHTML().strip();
                this.autoAdd(new_value_el);
                input.value = keep_input;
                this.update();
              }
            }
          }
          break;
        case Event.KEY_UP:
        case Event.KEY_DOWN:
        case Event.KEY_RETURN:
        case Event.KEY_ESC:
          break;
        default:
          // If the user doesn't add comma after, the value is discarded upon submit
          this.current_input = input.value.strip().escapeHTML();
          this.update();

          // Removed Ajax.Request from here and moved to initialize,
          // now doesn't create server queries every search but only
          // refreshes the list on initialize (page load)
          if(this.searchTimeout) clearTimeout(this.searchTimeout);
            this.searchTimeout = setTimeout(function(){
              var sanitizer = new RegExp("[({[^$*+?\\\]})]","g");
              if(this.dosearch) this.autoShow(input.value.replace(sanitizer,"\\$1"));
          }.bind(this), 250);
      }
    }.bind(this));
    input.observe(Prototype.Browser.IE ? 'keydown' : 'keypress', function(e) {
      if ((e.keyCode == Event.KEY_RETURN) && this.autoenter) e.stop();
      this.autoenter = false;
    }.bind(this));
    return li;
  },

  createBox: function($super,text, options) {
    var li = $super(text, options);
    li.observe('mouseover',function() {
      this.addClassName('bit-hover');
    }).observe('mouseout',function() {
      this.removeClassName('bit-hover')
    });
    var a = new Element('a', {
      'href': '#',
      'class': 'closebutton'
    });
    a.observe('click',function(e) {
      e.stop();
      if(! this.current) this.focus(this.maininput);
      this.dispose(li);
    }.bind(this));
    li.insert(a).cacheData('text', Object.toJSON(text));
    return li;
  }
});

