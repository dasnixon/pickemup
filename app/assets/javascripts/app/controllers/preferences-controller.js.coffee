preference_app.controller "PreferencesController", ($scope, $http, $location, $state, $stateParams, Preference) ->

  $scope.preference     = {}
  $scope.errors         = []
  $scope.success        = ''
  $scope.error_updating = ''

  if $state.current.name == 'edit'
    Preference.getPreference
      user_id: $stateParams['id'],
      action: 'get_preference'

    , (response) ->
      response.expected_salary = response.expected_salary.toLocaleString() if response.expected_salary
      response.skills = chunk response.skills, 6 if response.skills
      response.locations = chunk response.locations, 6 if response.locations
      response.industries = chunk response.industries, 6 if response.industries
      response.positions = chunk response.positions, 5 if response.positions
      response.settings = chunk response.settings, 6 if response.settings
      response.dress_codes = chunk response.dress_codes, 6 if response.dress_codes
      response.company_types = chunk response.company_types, 6 if response.company_types
      response.perks = chunk response.perks, 7 if response.perks
      response.practices = chunk response.practices, 6 if response.practices
      response.levels = chunk response.levels, 6 if response.levels
      $scope.preference = response

    , (response) ->
      $scope.error_updating = 'Unable to fetch your preferences at this time.'

  $scope.update = ->
    Preference.update
      user_id: $scope.preference.user_id,
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
        remote: $scope.preference.remote
        open_source: $scope.preference.open_source
        expected_salary: $scope.preference.expected_salary.replace(/,/g, "") if $scope.preference.expected_salary
        potential_availability: $scope.preference.potential_availability
        company_size: $scope.preference.company_size
        work_hours: $scope.preference.work_hours
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
      $location.path "/users/" + $scope.preference.user_id + "/preferences"
      $scope.preference.errors          = []
      $scope.success                    = 'Successfully updated your preferences.'
      $scope.error_updating             = ''
      $scope.preference.expected_salary = addCommas($scope.preference.expected_salary)

    , (response) ->
      $scope.preference.errors = response['data']['errors']
      $scope.error_updating    = 'Unable to update your preferences. See specific error messages below.'
      $scope.success           = ''
