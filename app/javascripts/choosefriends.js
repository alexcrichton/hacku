//= require <yui>
//= require <jquery/textboxlist.autocomplete>

YUI().use('io', function(Y) {

	Y.io('/grabfriends.js', {
		on:{success: function(garbage, o){
			eval(o.responseText)
			}
		}
	});
});
