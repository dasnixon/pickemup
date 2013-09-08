$ ->
  emailCheck = (email) ->
    if !email.match(/^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/)
      return false
    else
      return true

  clearErrors = ->
    $(".form_errors").hide()
    $(".form_errors").val('')

  $("#new_company").submit ->
    password = $('#company_password').val()
    confirmation = $('#company_password_confirmation').val()
    companyName = $('#company_name').val()
    email = $('#company_email').val()

    if !emailCheck(email)
      $(".form_errors").addClass("alert alert-error")
      $(".form_errors").text("Please enter a valid email address.").show()
      $(".form_errors").click ->
        clearErrors()
        return false
      return false

    if companyName.length == 0
      $(".form_errors").addClass("alert alert-error")
      $(".form_errors").text("Please enter a valid company name.").show()
      $(".form_errors").click ->
        clearErrors()
        return false
      return false

    if password.length < 8
      $(".form_errors").addClass("alert alert-error")
      $(".form_errors").text("Password must be at least 8 characters").show()
      $(".form_errors").click ->
        clearErrors()
      return false

    if password != confirmation
      $(".form_errors").addClass("alert alert-error")
      $(".form_errors").text("Password and Confirmation did not match").show()
      $(".form_errors").click ->
        clearErrors()
        return false
      return false
