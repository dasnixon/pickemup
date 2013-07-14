app.controller "PreferencesController", ($scope, $http, $location, $state, $stateParams, Preference) ->

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

    , (response) ->
      $location.path "/users/" + $scope.preference.user_id + "/preferences"

    , (response) ->
