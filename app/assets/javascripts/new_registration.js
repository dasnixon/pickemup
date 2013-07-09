function stripeResponseHandler(status, response) {
   if (response.error) {
      $('#stripe_error').text(response.error.message)
      $('input[type=submit]').attr('disabled', false)
   } else {
      $('#_stripe_card_token').val(response.id)
      $('#new_subscription')[0].submit()
    };
}

$(function() {
  $('#new_subscription').submit(function(event) {
    // Disable the submit button to prevent repeated clicks
    $('.submit-button').prop('disabled', true);

    Stripe.createToken({
      number: $('.card-number').val(),
      cvc: $('.card-cvc').val(),
      exp_month: $('.card-expiry-month').val(),
      exp_year: $('.card-expiry-year').val()
    }, stripeResponseHandler);

    // Prevent the form from submitting with the default action
    return false;
  });
});
