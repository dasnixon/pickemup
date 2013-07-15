app.config ($stateProvider, $urlRouterProvider, $locationProvider) ->
  $locationProvider.html5Mode(true)

  $stateProvider
    .state "edit",
      url: "/users/:id/preferences"
      views:
        "":
          controller: "PreferencesController"
          templateUrl: "/assets/preferences/edit.html.haml"

  $urlRouterProvider.otherwise("/")
