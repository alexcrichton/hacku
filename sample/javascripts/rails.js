//= require <jquery/rails>

jQuery.extend(jQuery, {
  railsPut: function(config) {
    var csrf_token = jQuery('meta[name=csrf-token]').attr('content'),
        csrf_param = jQuery('meta[name=csrf-param]').attr('content');

    if (!config.data) config.data = {};
    config.data[csrf_param] = csrf_token;
    config.type = 'PUT';
    config.dataType = 'script';

    jQuery.ajax(config);
  }
});

jQuery(function($) {
  $('*[data-remote]').live('ajax:loading', function () {
    $($['ajax-small']).insertAfter(this);
  });

  $('*[data-remote]').live('ajax:success ajax:complete ajax:failure', function () {
    $(this).next('img').remove();
  });
});
