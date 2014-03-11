pickemup.controller("TechStackCtrl", ['$scope', '$state', '$stateParams', '$location', 'TechStack', ($scope, $state, $stateParams, $location, TechStack) ->
  angular.extend $scope,
    new SharedCtrl($scope)
    techStack:      {}
    errors:         []
    success:        ''
    error_updating: ''

  if $state.current.name == "tech_stack_edit"
    TechStack.editTechStack.retrieveTechStack
      tech_stack_id: $stateParams['tech_stack_id'],
      company_id: $stateParams['company_id'],
      action: 'retrieve_tech_stack'
    , (response) ->
      response.back_end_languages = chunk(response.back_end_languages, 6)
      response.front_end_languages = chunk(response.front_end_languages, 6)
      response.dev_ops_tools = chunk(response.dev_ops_tools, 6)
      response.frameworks = chunk(response.frameworks, 6)
      response.relational_databases = chunk(response.relational_databases, 6)
      response.nosql_databases = chunk(response.nosql_databases, 6)
      $scope.data = response
      $scope.original = angular.copy($scope.data)

  else if $state.current.name == "tech_stack_new"
    TechStack.newTechStack.new
      company_id: $stateParams['company_id'],
      action: 'new'
    , (response) ->
      response.back_end_languages = chunk(response.back_end_languages, 6)
      response.front_end_languages = chunk(response.front_end_languages, 6)
      response.dev_ops_tools = chunk(response.dev_ops_tools, 6)
      response.frameworks = chunk(response.frameworks, 6)
      response.relational_databases = chunk(response.relational_databases, 6)
      response.nosql_databases = chunk(response.nosql_databases, 6)
      $scope.data = response
      $scope.original = angular.copy($scope.data)

  angular.extend $scope,
    create: ->
      TechStack.createTechStack.create
        company_id: $stateParams['company_id']
        action: 'create'
        tech_stack:
          name: $scope.data.name
          back_end_languages: unchunk($scope.data.back_end_languages)
          front_end_languages: unchunk($scope.data.front_end_languages)
          dev_ops_tools: unchunk($scope.data.dev_ops_tools)
          frameworks: unchunk($scope.data.frameworks)
          relational_databases: unchunk($scope.data.relational_databases)
          nosql_databases: unchunk($scope.data.nosql_databases)
      , (response) ->
        changeLocation($scope, $location, '/companies/' + $stateParams['company_id'] + '/tech_stacks', true)
      , (response) ->
        $scope.error_updating = 'Unable to create your tech stack.'
        $scope.success        = ''

    update: ->
      TechStack.editTechStack.update
        company_id: $stateParams['company_id']
        tech_stack_id: $stateParams['tech_stack_id']
        action: 'update_tech_stack'
        tech_stack:
          name: $scope.data.name
          back_end_languages: unchunk($scope.data.back_end_languages)
          front_end_languages: unchunk($scope.data.front_end_languages)
          dev_ops_tools: unchunk($scope.data.dev_ops_tools)
          frameworks: unchunk($scope.data.frameworks)
          relational_databases: unchunk($scope.data.relational_databases)
          nosql_databases: unchunk($scope.data.nosql_databases)
      , (response) ->
        $scope.success        = 'Successfully updated your tech stack.'
        $scope.data.errors    = []
        $scope.error_updating = ''
        $scope.dirty_message  = ''
        $scope.original       = angular.copy($scope.data)
      , (response) ->
        $scope.error_updating = 'Unable to update your tech stack.'
        $scope.success        = ''

    toggleActive: (attr) ->
      $scope.data[attr] = !$scope.data[attr]

    toggleActiveHash: (attr) ->
      attr.checked = !attr.checked

  $scope.$watch 'data', ( ->
    if angular.equals($scope.data, $scope.original)
      $scope.dirty_message = ''
    else
      $scope.success = ''
      $scope.dirty_message = 'You have made changes, make sure to click the \'Save\' button below.'
  ), true
])
