preference_app.controller "PreferencesController", ($scope, $http, $location, $state, $stateParams, Preference) ->

  $scope.preference     = {}
  $scope.skills_changed = {}
  $scope.errors         = []
  $scope.success        = ''
  $scope.error_updating = ''

  if $state.current.name == 'edit'
    Preference.getPreference
      user_id: $stateParams['id'],
      action: 'get_preference'

    , (response) ->
      for name, value of response.skills
        if value == "true"
          response.skills[name] = true
        else
          response.skills[name] = false

      response.expected_salary = response.expected_salary.toLocaleString() if response.expected_salary
      $scope.preference = response

    , (response) ->
      $scope.error_updating = 'Unable to fetch your preferences at this time.'

  $scope.updateSkills = (skill) ->
    if $scope.preference.skills[skill]
      $scope.skills_changed[skill] = false
    else
      $scope.skills_changed[skill] = true

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
        skills: $scope.skills_changed
        locations: $scope.preference.locations
        industries: $scope.preference.industries
        positions: $scope.preference.positions
        settings: $scope.preference.settings
        dress_codes: $scope.preference.dress_codes
        company_types: $scope.preference.company_types
        perks: $scope.preference.perks
        practices: $scope.preference.practices

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
