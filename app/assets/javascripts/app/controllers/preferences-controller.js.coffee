preference_app.controller "PreferencesController", ($scope, $location, $state, $stateParams, Preference) ->

  $scope.preference     = {}
  $scope.user_id        = ''
  $scope.original       = {}
  $scope.errors         = []
  $scope.success        = ''
  $scope.error_updating = ''
  $scope.dirty_message  = ''

  if $state.current.name == 'edit_preferences'
    $scope.user_id = $stateParams['id']
    Preference.getPreference
      user_id: $stateParams['id'],
      action: 'get_preference'

    , (response) ->
      $scope.preference                   = response
      $scope.preference.expected_salary   = $scope.preference.expected_salary.toLocaleString() if $scope.preference.expected_salary
      $scope.preference.skills            = chunk $scope.preference.skills, 6
      $scope.preference.locations         = chunk $scope.preference.locations, 6
      $scope.preference.industries        = chunk $scope.preference.industries, 6
      $scope.preference.position_titles   = chunk $scope.preference.position_titles, 6
      $scope.preference.company_types     = chunk $scope.preference.company_types, 6
      $scope.preference.perks             = chunk $scope.preference.perks, 7
      $scope.preference.practices         = chunk $scope.preference.practices, 6
      $scope.preference.experience_levels = chunk $scope.preference.experience_levels, 6
      $scope.preference.company_size      = chunk $scope.preference.company_size, 6
      $scope.original                     = angular.copy($scope.preference)

    , (response) ->
      $scope.error_updating = 'Unable to fetch your preferences at this time.'

  $scope.$watch 'preference', ( ->
    if angular.equals($scope.preference, $scope.original)
      $scope.dirty_message = ''
    else
      $scope.success = ''
      $scope.dirty_message = 'You have made changes, make sure to click the \'Save\' button below.'
  ), true

  $scope.selectAll = (objectScope) ->
    for object in unchunk objectScope
      object.checked = true

  $scope.unselectAll = (objectScope) ->
    for object in unchunk objectScope
      object.checked = false

  $scope.selectAllBenefits = ->
    $scope.preference.healthcare     = true
    $scope.preference.dentalcare     = true
    $scope.preference.visioncare     = true
    $scope.preference.life_insurance = true
    $scope.preference.paid_vacation  = true
    $scope.preference.equity         = true
    $scope.preference.bonuses        = true
    $scope.preference.retirement     = true
    $scope.preference.fulltime       = true
    $scope.preference.us_citizen     = true
    $scope.preference.open_source    = true
    $scope.preference.remote         = true

  $scope.unselectAllBenefits = ->
    $scope.preference.healthcare     = false
    $scope.preference.dentalcare     = false
    $scope.preference.visioncare     = false
    $scope.preference.life_insurance = false
    $scope.preference.paid_vacation  = false
    $scope.preference.equity         = false
    $scope.preference.bonuses        = false
    $scope.preference.retirement     = false
    $scope.preference.fulltime       = false
    $scope.preference.us_citizen     = false
    $scope.preference.open_source    = false
    $scope.preference.remote         = false

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
        remote: $scope.preference.remote
        potential_availability: $scope.preference.potential_availability
        work_hours: $scope.preference.work_hours
        company_size: unchunk $scope.preference.company_size
        skills: unchunk $scope.preference.skills
        locations: unchunk $scope.preference.locations
        industries: unchunk $scope.preference.industries
        position_titles: unchunk $scope.preference.position_titles
        company_types: unchunk $scope.preference.company_types
        perks: unchunk $scope.preference.perks
        practices: unchunk $scope.preference.practices
        experience_levels: unchunk $scope.preference.experience_levels

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
