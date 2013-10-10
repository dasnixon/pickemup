angular.module('salary-between', []).directive 'salarybetween', ->
  restrict: 'A',
  link: (scope, elm, attr) ->
    elm.slider().on 'slide', (ev) ->
      salary = ev.value
      scope.job_listings = _.filter scope.retainedMatches, (match) ->
        (salary == 0 or salary == 1000000) or (salary >= match.salary_range_low and salary <= match.salary_range_high)
      scope.$apply()
