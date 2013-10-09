angular.module('ui-collapse', []).directive 'uicollapse', ->
  restrict: 'A',
  link: (scope, elm, attr) ->
    elm.collapse 'hide'
    $('.accordion-toggle').click ->
      if $('#collapseOne').hasClass('in')
        $('#collapseOne').collapse('hide')
        $('#collapseOne').removeClass('in')
      else
        $('#collapseOne').collapse('show')
