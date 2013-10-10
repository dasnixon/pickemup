$ ->
  $(".message_notification").delay(800).fadeIn "normal", ->
    $(this).delay(3000).fadeOut()

  bodyHeight = $('.total-body-info').height()
  $('.right-sidebar-info').height(bodyHeight)
