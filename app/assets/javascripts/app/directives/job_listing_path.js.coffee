angular.module('job-listing-path', []).directive 'joblistingpath', [() ->
  restrict: 'A',
  link: (scope, element, attrs) ->
    el = element.click()[0]
    if attrs.companyId == ''
      el.href = attrs.link
    else
      el.href = '/companies/' + attrs.companyId + '/job_listings/' + attrs.listingId
]
