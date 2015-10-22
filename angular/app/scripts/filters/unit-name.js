'use strict';

/**
 * @ngdoc filter
 * @name fleetuiApp.filter:serviceName
 * @function
 * @description
 * # serviceName
 * Filter in the fleetuiApp.
 */
angular.module('fleetuiApp')
  .filter('unitName', function () {
    var unitTypes = /(.+)\.(service|socket|device|mount|automount|timer|path)$/;
    return function (input) {
      if(input) {
        return input.match(unitTypes) ? input.match(unitTypes)[1] : null;
      } else {
        return null;
      }
    };
  });
