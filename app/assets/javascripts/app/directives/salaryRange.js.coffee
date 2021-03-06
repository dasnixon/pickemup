angular.module('salary-range', []).directive 'salaryrange', ->
  restrict: 'A',
  link: (scope, elm, attr) ->
    scope.resetRange = ->
      elm.slider('setValue', [0,300000])
      scope.matches = scope.retainedMatches
    elm.slider().on 'slide', (ev) ->
      lowSalary = ev.value[0]
      highSalary = ev.value[1]
      scope.matches = _.filter scope.retainedMatches, (match) ->
        match.expected_salary >= lowSalary and match.expected_salary <= highSalary
      scope.$apply()
