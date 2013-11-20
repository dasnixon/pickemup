angular.module('message-threshold', []).directive 'messagethreshold', ->
  restrict: 'A',
  link: (scope, elm, attr) ->
    data = scope.data || scope.preference
    elm.slider().on 'slide', (ev) ->
      data.match_threshold = ev.value
      scope.$apply()
    elm.data('slider').setValue(data.match_threshold)
