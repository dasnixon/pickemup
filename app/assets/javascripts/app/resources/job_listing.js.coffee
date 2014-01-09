jobListing.factory('JobListing', ['$resource', ($resource) ->
  editListing: $resource('/companies/:company_id/job_listings/:job_listing_id/:action.json',
    {job_listing_id: '@job_listing_id', company_id: '@company_id', action: '@action'},
    'get':    {method:'GET'},
    'update': {method:'PATCH'},
    'retrieveListing': {method: 'GET'},
    'searchUsers': {method:'GET'},
  )
  newListing: $resource('/companies/:company_id/job_listings/new.json',
    {company_id: '@company_id'},
    'new': {method:'GET'},
  )
  createListing: $resource('/companies/:company_id/job_listings.json',
    {company_id: '@company_id'},
    'create': {method: 'POST'}
  )
])
