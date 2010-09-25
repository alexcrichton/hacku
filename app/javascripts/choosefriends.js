//= require <yui>
//= require <jquery/textboxlist.autocomplete>

YUI().use('io', function(Y) {

  var query = window.location.search.substring(1);
  var vars = query.split('&');
  var selected_ids = '';
  for (var i=0;i<vars.length;i++) {
    var pair = vars[i].split("=");
    if (pair[0] == 'selected_ids') {
      selected_ids = pair[1];
    }
  }

  Y.io('/grabfriends.js', {
    data: 'selected_ids='+selected_ids,
    on:{success: function(garbage, o){
      eval(o.responseText)
      }
    }
  });
});
