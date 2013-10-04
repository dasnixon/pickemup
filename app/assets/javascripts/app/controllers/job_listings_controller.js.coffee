jobListing.controller("JobListingCtrl", ['$scope', '$http', '$state', '$stateParams', '$location', 'JobListing', ($scope, $http, $state, $stateParams, $location, JobListing) ->

  $scope.jobListing     = {}
  $scope.errors         = []
  $scope.success        = ''
  $scope.error_updating = ''

  if $state.current.name == "edit"
    JobListing.editListing.retrieveListing
      job_listing_id: $stateParams['job_listing_id'],
      company_id: $stateParams['company_id'],
      action: 'retrieve_listing'
    , (response) ->
      response.job_listing.acceptable_languages = chunk(response.job_listing.acceptable_languages, 6)
      response.job_listing.locations = chunk(response.job_listing.locations, 6)
      response.job_listing.practices = chunk(response.job_listing.practices, 6)
      response.job_listing.special_characteristics = chunk(response.job_listing.special_characteristics, 6)
      response.job_listing.experience_levels = chunk(response.job_listing.experience_levels, 5)
      response.job_listing.position_titles = chunk(response.job_listing.position_titles, 5)
      response.job_listing.perks = chunk(response.job_listing.perks, 6)
      $scope.tech_stacks = response.tech_stacks
      $scope.data = response.job_listing
      $scope.original = angular.copy($scope.data)

  else if $state.current.name == "new"
    JobListing.newListing.new
      company_id: $stateParams['company_id'],
      action: 'new'
    , (response) ->
      response.job_listing.acceptable_languages = chunk(response.job_listing.acceptable_languages, 6)
      response.job_listing.locations = chunk(response.job_listing.locations, 6)
      response.job_listing.practices = chunk(response.job_listing.practices, 6)
      response.job_listing.special_characteristics = chunk(response.job_listing.special_characteristics, 6)
      response.job_listing.experience_levels = chunk(response.job_listing.experience_levels, 5)
      response.job_listing.position_titles = chunk(response.job_listing.position_titles, 5)
      response.job_listing.perks = chunk(response.job_listing.perks, 6)
      $scope.tech_stacks = response.tech_stacks
      $scope.data = response.job_listing
      $scope.original = angular.copy($scope.data)

  else if $state.current.name == "search_users"
    JobListing.editListing.searchUsers
      job_listing_id: $stateParams['job_listing_id'],
      company_id: $stateParams['company_id'],
      action: 'search_users'

    , (response) ->
      $scope.matches = response.matches
      $scope.job_listing_id = response.job_listing_id
      $scope.company_id = response.company_id

  $scope.$watch 'data', ( ->
    if angular.equals($scope.data, $scope.original)
      $scope.dirty_message = ''
    else
      $scope.success = ''
      $scope.dirty_message = 'You have made changes, make sure to click the \'Save\' button below.'
  ), true

  $scope.create = ->
    JobListing.createListing.create
      company_id: $stateParams['company_id'],
      action: 'create',
      job_listing:
        job_title: $scope.data.job_title
        job_description: $scope.data.job_description
        synopsis: $scope.data.synopsis
        locations: unchunk($scope.data.locations)
        position_titles: unchunk($scope.data.position_titles)
        experience_levels: unchunk($scope.data.experience_levels)
        salary_range_low: $scope.data.salary_range_low
        salary_range_high: $scope.data.salary_range_high
        vacation_days: $scope.data.vacation_days
        healthcare: $scope.data.healthcare
        dental: $scope.data.dental
        vision: $scope.data.vision
        life_insurance: $scope.data.life_insurance
        retirement: $scope.data.retirement
        equity: $scope.data.equity
        bonuses: $scope.data.bonuses
        perks: unchunk($scope.data.perks)
        fulltime: $scope.data.fulltime
        estimated_work_hours: $scope.data.estimated_work_hours
        remote: $scope.data.remote
        hiring_time: $scope.data.hiring_time
        special_characteristics: unchunk($scope.data.special_characteristics)
        acceptable_languages: unchunk($scope.data.acceptable_languages)
        practices: unchunk($scope.data.practices)
        tech_stack_id: $scope.data.tech_stack_id
        active: true
    , (response) ->
      changeLocation($scope, $location, '/companies/' + $stateParams['company_id'] + '/job_listings', true)
    , (response) ->
      $scope.error_updating = 'Unable to create your job listing.'
      $scope.success        = ''

  $scope.update = ->
    JobListing.editListing.update
      company_id: $stateParams['company_id'],
      job_listing_id: $stateParams['job_listing_id'],
      action: 'update_listing',
      job_listing:
        job_title: $scope.data.job_title
        job_description: $scope.data.job_description
        synopsis: $scope.data.synopsis
        locations: unchunk($scope.data.locations)
        position_titles: unchunk($scope.data.position_titles)
        experience_levels: unchunk($scope.data.experience_levels)
        salary_range_low: $scope.data.salary_range_low
        salary_range_high: $scope.data.salary_range_high
        vacation_days: $scope.data.vacation_days
        healthcare: $scope.data.healthcare
        dental: $scope.data.dental
        vision: $scope.data.vision
        life_insurance: $scope.data.life_insurance
        retirement: $scope.data.retirement
        equity: $scope.data.equity
        bonuses: $scope.data.bonuses
        perks: unchunk($scope.data.perks)
        fulltime: $scope.data.fulltime
        estimated_work_hours: $scope.data.estimated_work_hours
        remote: $scope.data.remote
        hiring_time: $scope.data.hiring_time
        special_characteristics: unchunk($scope.data.special_characteristics)
        acceptable_languages: unchunk($scope.data.acceptable_languages)
        practices: unchunk($scope.data.practices)
        tech_stack_id: $scope.data.tech_stack_id
    , (response) ->
      $scope.success        = 'Successfully updated the job listing.'
      $scope.data.errors    = []
      $scope.error_updating = ''
      $scope.dirty_message  = ''
      $scope.original       = angular.copy($scope.data)
    , (response) ->
      $scope.error_updating = 'Unable to update your job listing.'
      $scope.success        = ''

  $scope.toggleActive = (attr) ->
    $scope.data[attr] = !$scope.data[attr]

  $scope.toggleActiveHash = (attr) ->
    attr.checked = !attr.checked
])
