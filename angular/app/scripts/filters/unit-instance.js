'use strict';

/**
 * @ngdoc filter
 * @name fleetuiApp.filter:unitInstance
 * @function
 * @description
 * # unitInstance
 * Filter in the fleetuiApp.
 */
angular.module('fleetuiApp')
  .filter('unitInstance', function () {
    var unitTypes = /(.+)@(.+)\.(service|socket|device|mount|automount|timer|path)$/;
    return function (input) {
      if(input) {
        return input.match(unitTypes) ? input.match(unitTypes)[2] : null;
      } else {
        return null;
      }
    };
  });
