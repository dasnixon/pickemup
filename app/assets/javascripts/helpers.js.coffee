$ ->
  $.ajaxSetup
    beforeSend: (xhr) ->
      xhr.setRequestHeader "Accept", "application/json"
    cache: false

  $(".message_notification").delay(800).fadeIn "normal", ->
    $(this).delay(3000).fadeOut()

  if $("#company_search").length > 0
    $("#company_search").autocomplete(
      source: "/company_search"
    ).data("ui-autocomplete")._renderItem = (ul, item) ->
      $("<li>").append("<a href='/companies/" + item.id + "'><img src='" + item.logo + "' class='img-rounded' height='10' width='25' />&nbsp; &nbsp;" + item.name + "</a>").appendTo ul
