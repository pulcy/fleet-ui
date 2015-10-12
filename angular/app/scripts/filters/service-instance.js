'use strict';

/**
 * @ngdoc filter
 * @name fleetuiApp.filter:serviceInstance
 * @function
 * @description
 * # serviceInstance
 * Filter in the fleetuiApp.
 */
angular.module('fleetuiApp')
  .filter('serviceInstance', function () {
    return function (input) {
      if(input) {
        return input.indexOf('@') > 0 ? input.substring(input.lastIndexOf('@') + 1, input.lastIndexOf('.service')) : "";
      } else {
        return null;
      }
    };
  });
