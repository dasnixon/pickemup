$ ->
  stripeResponseHandler = (status, response) ->
    if response.error
      $('#stripe_error').text(response.error.message)
      $('.submit-button').prop('disabled', false)
    else
      token = response.id
      $('#new_subscription').append($('<input type="hidden" name="stripe_card_token" />').val(token))
      $('#new_subscription').get(0).submit()

  $('#new_subscription').submit event, ->
    $('.submit-button').prop('disabled', true)

    Stripe.card.createToken({
      number: $('.card-number').val(),
      cvc: $('.card-cvc').val(),
      exp_month: $('.card-expiry-month').val(),
      exp_year: $('.card-expiry-year').val()
    }, stripeResponseHandler)
    return false
