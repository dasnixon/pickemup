angular.module('message-threshold', []).directive 'messagethreshold', ['$timeout', (timer) ->
  restrict: 'A',
  require: '^ngModel',
  link: (scope, elm, attr) ->
    setThreshold = ->
      data = scope.data || scope.preference
      elm.slider().on 'slide', (ev) ->
        data.match_threshold = ev.value
        scope.$apply()
      elm.data('slider').setValue(data.match_threshold)

    timer(setThreshold, 200)
]
