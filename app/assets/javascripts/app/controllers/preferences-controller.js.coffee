preference_app.controller "PreferencesController", ($scope, $http, $location, $state, $stateParams, Preference) ->

  $scope.preference     = {}
  $scope.user_id        = ''
  $scope.original       = {}
  $scope.errors         = []
  $scope.success        = ''
  $scope.error_updating = ''
  $scope.dirty_message  = ''

  if $state.current.name == 'edit'
    $scope.user_id = $stateParams['id']
    Preference.getPreference
      user_id: $stateParams['id'],
      action: 'get_preference'

    , (response) ->
      response.expected_salary = response.expected_salary.toLocaleString() if response.expected_salary
      response.skills          = response.skills
      response.locations       = response.locations
      response.industries      = response.industries
      response.positions       = response.positions
      response.settings        = response.settings
      response.dress_codes     = response.dress_codes
      response.company_types   = response.company_types
      response.perks           = response.perks
      response.practices       = response.practices
      response.levels          = response.levels
      response.remote          = response.remote
      response.company_size    = response.company_size
      $scope.preference        = response
      $scope.original          = angular.copy($scope.preference)

    , (response) ->
      $scope.error_updating = 'Unable to fetch your preferences at this time.'

  $scope.$watch 'preference', ( ->
    if angular.equals($scope.preference, $scope.original)
      $scope.dirty_message = ''
    else
      $scope.success = ''
      $scope.dirty_message = 'You have made changes, make sure to click the \'Save\' button below.'
  ), true

  $scope.update = ->
    Preference.update
      user_id: $scope.user_id,
      action: 'update_preference',
      preference:
        healthcare: $scope.preference.healthcare
        dentalcare: $scope.preference.dentalcare
        visioncare: $scope.preference.visioncare
        life_insurance: $scope.preference.life_insurance
        paid_vacation: $scope.preference.paid_vacation
        equity: $scope.preference.equity
        bonuses: $scope.preference.bonuses
        retirement: $scope.preference.retirement
        fulltime: $scope.preference.fulltime
        us_citizen: $scope.preference.us_citizen
        remote: $scope.preference.remote
        open_source: $scope.preference.open_source
        expected_salary: $scope.preference.expected_salary.replace(/,/g, "") if $scope.preference.expected_salary
        potential_availability: $scope.preference.potential_availability
        company_size: $scope.preference.company_size
        work_hours: $scope.preference.work_hours
        skills: $scope.preference.skills
        locations: $scope.preference.locations
        industries: $scope.preference.industries
        positions: $scope.preference.positions
        settings: $scope.preference.settings
        dress_codes: $scope.preference.dress_codes
        company_types: $scope.preference.company_types
        perks: $scope.preference.perks
        practices: $scope.preference.practices
        levels: $scope.preference.levels

    , (response) ->
      $scope.preference.expected_salary = addCommas(response.preference.expected_salary)
      $scope.preference.errors          = []
      $scope.success                    = 'Successfully updated your preferences.'
      $scope.error_updating             = ''
      $scope.dirty_message              = ''
      $scope.original                   = angular.copy($scope.preference)

    , (response) ->
      $scope.preference.errors = response['data']['errors']
      $scope.error_updating    = 'Unable to update your preferences. See specific error messages below.'
      $scope.success           = ''
