jobListing.factory('JobListing', ['$resource', ($resource) ->
  editListing: $resource('/companies/:company_id/job_listings/:job_listing_id/:action',
    {job_listing_id: '@job_listing_id', company_id: '@company_id', action: '@action'},
    'get':    {method:'GET'},
    'update': {method:'PUT'},
    'retrieveListing': {method: 'GET'}
  )
  newListing: $resource('/companies/:company_id/job_listings/new',
    {company_id: '@company_id'},
    'new': {method:'GET'},
  )
  createListing: $resource('/companies/:company_id/job_listings',
    {company_id: '@company_id'},
    'create': {method: 'POST'}
  )
])
