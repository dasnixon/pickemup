preference_app.controller "PreferencesController", ($scope, $http, $location, $state, $stateParams, Preference) ->

  $scope.preference = {}

  if $state.current.name == 'edit'
    Preference.getPreference
      user_id: $stateParams['id'],
      action: 'get_preference'

    , (response) ->
      $scope.preference = response

    , (response) ->

  $scope.update = ->
    Preference.update
      user_id: $scope.preference.user_id,
      action: 'update_preference',
      preference:
        expected_salary: $scope.preference.expected_salary
        healthcare: $scope.preference.healthcare
        vacation_days: $scope.preference.vacation_days
        equity: $scope.preference.equity
        bonuses: $scope.preference.bonuses
        retirement: $scope.preference.retirement
        perks: $scope.preference.perks
        practices: $scope.preference.practices
        fulltime: $scope.preference.fulltime
        remote: $scope.preference.remote
        potential_availability: $scope.preference.potential_availability
        open_source: $scope.preference.open_source
        company_size: $scope.preference.company_size
        skills: $scope.preference.skills
        locations: $scope.preference.locations
        industries: $scope.preference.industries
        positions: $scope.preference.positions
        settings: $scope.preference.settings
        dress_codes: $scope.preference.dress_codes
        company_types: $scope.preference.company_types

    , (response) ->
      $location.path "/users/" + $scope.preference.user_id + "/preferences"

    , (response) ->
