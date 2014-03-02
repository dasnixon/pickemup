angular.module('job-listing-application-path', []).directive 'joblistingapplicationpath', [() ->
  restrict: 'A',
  link: (scope, element, attrs) ->
    el = element.click()[0]
    if attrs.companyId == ''
      el.href = attrs.link
    else
      el.href = '/users/' + attrs.userId + '/messages/new?job_listing_id=' + attrs.listingId + '&receiver=' + attrs.companyId
]
