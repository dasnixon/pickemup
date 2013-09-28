userEdit.controller("UsersController", ['$scope', '$location', '$state', '$stateParams', 'User', ($scope, $location, $state, $stateParams, User) ->

  $scope.user           = {}
  $scope.original       = {}
  $scope.errors         = []
  $scope.success        = ''
  $scope.error_updating = ''
  $scope.dirty_message  = ''

  if $state.current.name == 'edit'
    User.get
      id: $stateParams['id'],
      action: 'edit'

    , (response) ->
      $scope.user = response
      $scope.original = angular.copy($scope.user)
    , (response) ->
      $scope.error_updating = 'There were issues updating your information.'
  else if $state.current.name == 'search_jobs'
    User.searchJobs
      id: $stateParams['id'],
      action: 'search_jobs'
    , (response) ->
      $scope.job_listings = response.job_listings
      $scope.user_id = response.user_id

  $scope.update = ->
    User.update
      id: $stateParams['id'],
      action: '',
      user:
        name: $scope.user.name
        email: $scope.user.email
        location: $scope.user.location
        description: $scope.user.description

    , (response) ->
      $scope.user.errors    = []
      $scope.success        = 'Successfully updated your profile information.'
      $scope.error_updating = ''
      $scope.dirty_message  = ''
      $scope.original       = angular.copy($scope.user)

    , (response) ->
      $scope.user.errors    = response['data']['errors']
      $scope.error_updating = 'Unable to update your profile. See specific error messages below.'
      $scope.success        = ''

  $scope.$watch 'user', ( ->
    if angular.equals($scope.user, $scope.original)
      $scope.dirty_message = ''
    else
      $scope.success = ''
      $scope.dirty_message = 'You have made changes, make sure to click the \'Save\' button below.'
  ), true
])
