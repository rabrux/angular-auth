angular
  .module 'auth', []
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
  # Before Request Hook
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
            config.headers['Authorization'] = token
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
    '$localStorage'
    ($http, url, $db) ->
      {
        register: ( data ) -> $http.post url + '/signup', angular.toJson( data )
        verify: ( key ) -> $http.post "#{ url }/verify/#{ key }"
        recovery: ( email ) -> $http.post "#{ url }/recovery", angular.toJson( { email: email } )
        passwd: ( data ) -> $http.put "#{ url }/passwd", angular.toJson( data )
        login: ( data ) -> $http.post "#{ url }/authenticate", angular.toJson( data )
        ping: -> $http.get "#{ url }/ping"
        saveCredentials: ( res ) ->
          if !res or !res.token
            return console.error 'SaveCredentials', res
          $db.set 'token', res.token
        loadCredentials: -> $db.get 'token'
        deleteCredentials: -> $db.delete 'token'
      }
  ]
