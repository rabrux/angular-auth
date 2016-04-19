angular.module( 'auth', [] )
  .provider 'auth', [ ->
    {
      baseUrl: ''
      init: ( data ) ->
        @baseUrl = data.url.replace(/(\/)*$/i, '')
      $get: ->
        {
          baseUrl: @baseUrl
        }
    }
  ]
  .factory 'beforeRequest', [
    '$localStorage'
    '$q'
    'baseUrl'
    ($db, $q, url) ->
      {
        request: (config) ->
          config.respondType = 'json'
          token = $db.get 'token'
          if token and config.url.indexOf( url ) == 0
            console.log config
            config.headers['x-guid'] = token
          config
      }
  ]
  .config [
    '$httpProvider'
    ($httpProvider) ->
      $httpProvider.defaults.useXDomain = true
      $httpProvider.interceptors.push 'beforeRequest'
      return
  ]
  .factory '$localStorage', [
    '$window'
    ($window) ->
      {
        set: (key, value) ->
          $window.localStorage[key] = JSON.stringify(value)
          return
        get: (key) ->
          JSON.parse $window.localStorage[key] or null
        delete: (key) ->
          $window.localStorage.removeItem key
          return

      }
  ]
  .factory 'baseUrl', [
    'auth'
    (auth) ->
      auth.baseUrl
  ]
  .service '$auth', [
    '$http'
    'baseUrl'
    ($http, url) ->
      {
        register: ( data ) ->
          $http
            .post url + '/register', angular.toJson( data )
            .success (response) ->
              response
            .error (response) ->
              response
        verify: ( key ) ->
          $http
            .get "#{ url }/verify/#{ key }"
            .success (response) ->
              response
            .error (response) ->
              response
        login: ( data ) ->
          $http
            .post "#{ url }/login", angular.toJson( data )
            .success (response) ->
              response
            .error (response) ->
              response
        logout: ->
          $http
            .delete "#{ url }/logout"
            .success (response) ->
              response
            .error (response) ->
              response
        ping: ->
          $http
            .get "#{ url }/ping"
            .success (response) ->
              response
            .error (response) ->
              response
      }
  ]