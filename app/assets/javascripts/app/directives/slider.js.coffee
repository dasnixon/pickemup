angular.module('ui-slider', []).directive 'uislider', ->
  restrict: 'A',
  link: (scope, elm, attr) ->
    elm.slider().on 'slide', (ev) ->
      lowSalary = ev.value[0]
      highSalary = ev.value[1]
      scope.matches = _.filter scope.retainedMatches, (match) ->
        match.expected_salary >= lowSalary and match.expected_salary <= highSalary
      scope.$apply()
