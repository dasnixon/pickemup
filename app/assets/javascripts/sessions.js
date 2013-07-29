$(document).ready(function () {
  $("#new_company").submit(function() {
    var password = $('#company_password').val()
    var confirmation = $('#company_password_confirmation').val()
    var companyName = $('#company_name').val()
    var email = $('#company_email').val()
    if (email.match(/^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/)) {
      if (companyName.length > 0) {
        if (password.length >= 8) {
          if (password == confirmation) {
            return true;
          } else {
            $(".form_errors").text("Password and Confirmation did not match").show().fadeOut(5000);
            return false;
          }
        } else {
          $(".form_errors").text("Password must be at least 8 characters").show().fadeOut(5000);
          return false;
        }
      } else {
        $(".form_errors").text("All fields must be filled out").show().fadeOut(5000);
        return false;
      }
    } else {
      $(".form_errors").text("Please enter a valid email address").show().fadeOut(5000);
      return false;
    }
  });

  $("#company_sign_in").submit(function() {
    var password = $('#password').val()
    var email = $('#email').val()
    if (email.match(/^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/)) {
      if (password.length >= 8) {
        return true;
      } else {
        $(".form_errors").text("Invalid Password").show().fadeOut(5000);
        return false;
      }
    } else {
      $(".form_errors").text("Invalid Email").show().fadeOut(5000);
      return false;
    }
  });
});
