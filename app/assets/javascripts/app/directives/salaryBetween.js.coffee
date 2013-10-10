angular.module('salary-between', []).directive 'salarybetween', ->
  restrict: 'A',
  link: (scope, elm, attr) ->
    scope.clearSalaryBetween = ->
      scope.job_listings = scope.retainedMatches
      elm.slider('setValue', 0)
    elm.slider().on 'slide', (ev) ->
      salary = ev.value
      scope.job_listings = _.filter scope.retainedMatches, (match) ->
        (salary == 0 or salary == 300000) or (salary >= match.salary_range_low and salary <= match.salary_range_high)
      scope.$apply()
