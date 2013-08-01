techStack.controller("TechStackCtrl", ['$scope', '$http', '$state', '$stateParams', '$location', 'TechStack', function($scope, $http, $state, $stateParams, $location, TechStack) {
  $scope.techStack     = {}
  $scope.errors         = []
  $scope.success        = ''
  $scope.error_updating = ''

  if ($state.current.name == "edit") {
    TechStack.editTechStack.retrieveTechStack({
      tech_stack_id: $stateParams['tech_stack_id'],
      company_id: $stateParams['company_id'],
      action: 'retrieve_tech_stack'
    }, function(response) {
       response.back_end_languages = chunk(response.back_end_languages, 6)
       response.front_end_languages = chunk(response.front_end_languages, 6)
       response.dev_ops_tools = chunk(response.dev_ops_tools, 6)
       response.frameworks = chunk(response.frameworks, 6)
       $scope.data = response
    });
    return $scope.update = function() {
      TechStack.editTechStack.update({
        company_id: $stateParams['company_id'],
        tech_stack_id: $stateParams['tech_stack_id'],
        action: 'update_tech_stack',
        tech_stack: {
          name: $scope.data.name,
          back_end_languages: unchunk($scope.data.back_end_languages),
          front_end_languages: unchunk($scope.data.front_end_languages),
          dev_ops_tools: unchunk($scope.data.dev_ops_tools),
          frameworks: unchunk($scope.data.frameworks)
        }},
        function(response) {
          return $scope.success;
        }
    )};
  } else if($state.current.name == "new") {
    TechStack.newTechStack.new({
      company_id: $stateParams['company_id'],
      action: 'new'
    }, function(response) {
       response.back_end_languages = chunk(response.back_end_languages, 6)
       response.front_end_languages = chunk(response.front_end_languages, 6)
       response.dev_ops_tools = chunk(response.dev_ops_tools, 6)
       response.frameworks = chunk(response.frameworks, 6)
       $scope.data = response
    });
    return $scope.create = function() {
      debugger;
      TechStack.createTechStack.create({
        company_id: $stateParams['company_id'],
        action: 'create',
        tech_stack: {
          name: $scope.data.name,
          back_end_languages: unchunk($scope.data.back_end_languages),
          front_end_languages: unchunk($scope.data.front_end_languages),
          dev_ops_tools: unchunk($scope.data.dev_ops_tools),
          frameworks: unchunk($scope.data.frameworks)
        }},
        function(response) {
          return $scope.success;
        }
    )};
  }
}]);
