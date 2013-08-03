$ ->
  creditCard = $("#credit-card")
  cardGrandParent = creditCard.parent().parent()

  creditCard.on("cc:onReset cc:onGuess", ->
    cardGrandParent.removeClass().addClass "control-group"
  ).on("cc:onInvalid", ->
    cardGrandParent.removeClass().addClass "control-group error"
    $("#credit-card-type-text").text ""
  ).on("cc:onValid", (event, card, niceName) ->
    cardGrandParent.removeClass().addClass "control-group success"
  ).on("cc:onCardChange", (event, card, niceName) ->
    $("#credit-card-type-text").text niceName
  ).cardcheck iconLocation: "#accepted-cards-images"
