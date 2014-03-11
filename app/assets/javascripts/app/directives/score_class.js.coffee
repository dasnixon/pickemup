pickemup.directive "scoreClass", ->
  replace: false,
  scope: {
    score: '='
  },
  restrict: 'A',
  transclude: true,
  template: '<div ng-transclude=true></div>',
  link: (scope, iElm, iAttrs) ->
    score = if scope.score? then parseInt(scope.score) else 0

    cssClass =
      if 0 <= score <= 24
        'poor-score-color'
      else if 25 <= score <= 49
        'low-score-color'
      else if 50 <= score <= 74
        'medium-score-color'
      else
        'high-score-color'

    iElm.addClass(cssClass)
