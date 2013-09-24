preference_app.controller("PreferencesController", ['$scope', '$location', '$state', '$stateParams', 'Preference', ($scope, $location, $state, $stateParams, Preference) ->

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
      $scope.preference.perks             = chunk $scope.preference.perks, 5
      $scope.preference.practices         = chunk $scope.preference.practices, 6
      $scope.preference.experience_levels = chunk $scope.preference.experience_levels, 7
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

  $scope.toggleActive = (attr) ->
    @preference[attr] = !@preference[attr]

  $scope.toggleActiveHash = (attr) ->
    attr.checked = !attr.checked

  $scope.selectAllBenefits = ->
    @preference.healthcare     = true
    @preference.dental         = true
    @preference.vision         = true
    @preference.life_insurance = true
    @preference.vacation_days  = true
    @preference.equity         = true
    @preference.bonuses        = true
    @preference.retirement     = true

  $scope.unselectAllBenefits = ->
    @preference.healthcare     = false
    @preference.dental         = false
    @preference.vision         = false
    @preference.life_insurance = false
    @preference.vacation_days  = false
    @preference.equity         = false
    @preference.bonuses        = false
    @preference.retirement     = false

  $scope.update = ->
    Preference.update
      user_id: $scope.user_id,
      action: 'update_preference',
      preference:
        healthcare:             @preference.healthcare
        dental:                 @preference.dental
        vision:                 @preference.vision
        life_insurance:         @preference.life_insurance
        vacation_days:          @preference.vacation_days
        equity:                 @preference.equity
        bonuses:                @preference.bonuses
        retirement:             @preference.retirement
        fulltime:               @preference.fulltime
        us_citizen:             @preference.us_citizen
        open_source:            @preference.open_source
        expected_salary:        @preference.expected_salary.replace(/,/g, "") if $scope.preference.expected_salary
        remote:                 @preference.remote
        potential_availability: @preference.potential_availability
        work_hours:             @preference.work_hours
        willing_to_relocate:    @preference.willing_to_relocate
        company_size:           unchunk @preference.company_size
        skills:                 unchunk @preference.skills
        locations:              unchunk @preference.locations
        industries:             unchunk @preference.industries
        position_titles:        unchunk @preference.position_titles
        company_types:          unchunk @preference.company_types
        perks:                  unchunk @preference.perks
        practices:              unchunk @preference.practices
        experience_levels:      unchunk @preference.experience_levels

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
])
