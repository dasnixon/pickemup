$ ->
  shiftWindow = ->
    scrollBy 0, -70

  shiftWindow() if location.hash
  window.addEventListener "hashchange", shiftWindow
