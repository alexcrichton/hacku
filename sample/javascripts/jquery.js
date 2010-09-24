//= require <jquery/core>
//= require <jquery/ui>

jQuery.ajaxSetup({error: error});

function error() {
  jQuery('.ui-dialog-content').dialog('close');
  jQuery('img.loading').remove();
  jQuery('<p>Server Error... Please Try later</p>').dialog({
    modal:true,
    close: function() {
      jQuery('.ui-dialog').remove();
    }
  });
}

jQuery['small-ajax'] = "<img alt=\"Ajax-small\" class=\"loading\" src=\"/images/ajax-small.gif\" />";
jQuery['big-ajax'] = "<img alt=\"Ajax-big\" class=\"loading\" src=\"/images/ajax-big.gif\" />";
jQuery['huge-ajax'] = "<img alt=\"Ajax-huge\" class=\"loading\" src=\"/images/ajax-huge.gif\" />";
