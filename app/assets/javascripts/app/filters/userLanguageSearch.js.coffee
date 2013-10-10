angular.module('skillUserSearch', []).filter 'skills', ->
  (scope, keyword) ->
    if scope?
      if keyword?
        return _.filter scope, (match) ->
          found_matches = _.find match.skills, (skill) ->
            pattern = keyword.replace(/\s+/, "|")
            regex = new RegExp(pattern, 'ig')
            skill.match(regex)
          found_matches?
      else
        return scope
