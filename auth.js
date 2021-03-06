// Generated by CoffeeScript 1.11.1
(function() {
  angular.module('auth', []).provider('auth', [
    function() {
      return {
        baseUrl: '',
        init: function(data) {
          return this.baseUrl = data.url.replace(/(\/)*$/i, '');
        },
        $get: function() {
          return {
            baseUrl: this.baseUrl
          };
        }
      };
    }
  ]).factory('beforeRequest', [
    '$localStorage', '$q', 'baseUrl', function($db, $q, url) {
      return {
        request: function(config) {
          var token;
          config.respondType = 'json';
          token = $db.get('token');
          if (token && config.url.indexOf(url) === 0) {
            config.headers['Authorization'] = token;
          }
          return config;
        }
      };
    }
  ]).config([
    '$httpProvider', function($httpProvider) {
      $httpProvider.defaults.useXDomain = true;
      $httpProvider.interceptors.push('beforeRequest');
    }
  ]).factory('$localStorage', [
    '$window', function($window) {
      return {
        set: function(key, value) {
          $window.localStorage[key] = JSON.stringify(value);
        },
        get: function(key) {
          return JSON.parse($window.localStorage[key] || null);
        },
        "delete": function(key) {
          $window.localStorage.removeItem(key);
        }
      };
    }
  ]).factory('baseUrl', [
    'auth', function(auth) {
      return auth.baseUrl;
    }
  ]);

}).call(this);
