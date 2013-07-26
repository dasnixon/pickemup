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
      response.skills          = chunk response.skills, 6
      response.locations       = chunk response.locations, 6
      response.industries      = chunk response.industries, 6
      response.positions       = chunk response.positions, 6
      response.settings        = chunk response.settings, 6
      response.dress_codes     = chunk response.dress_codes, 6
      response.company_types   = chunk response.company_types, 6
      response.perks           = chunk response.perks, 7
      response.practices       = chunk response.practices, 6
      response.levels          = chunk response.levels, 6
      response.remote          = chunk response.remote, 6
      response.company_size    = chunk response.company_size, 6
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
        open_source: $scope.preference.open_source
        expected_salary: $scope.preference.expected_salary.replace(/,/g, "") if $scope.preference.expected_salary
        potential_availability: $scope.preference.potential_availability
        work_hours: $scope.preference.work_hours
        remote: unchunk $scope.preference.remote
        company_size: unchunk $scope.preference.company_size
        skills: unchunk $scope.preference.skills
        locations: unchunk $scope.preference.locations
        industries: unchunk $scope.preference.industries
        positions: unchunk $scope.preference.positions
        settings: unchunk $scope.preference.settings
        dress_codes: unchunk $scope.preference.dress_codes
        company_types: unchunk $scope.preference.company_types
        perks: unchunk $scope.preference.perks
        practices: unchunk $scope.preference.practices
        levels: unchunk $scope.preference.levels

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
