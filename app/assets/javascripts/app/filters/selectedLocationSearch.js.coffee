angular.module('locationSearch', []).filter 'location', ->
  (users, selectedLocations) ->
    if users?
      if selectedLocations.length > 0
        return _.filter users, (user) ->
          (_.intersection(user.locations, selectedLocations)).length > 0
      else
        return users
