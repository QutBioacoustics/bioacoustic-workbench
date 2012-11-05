'use strict';

/* App Module */

angular.module('baw', []).
    config(['$routeProvider', function($routeProvider) {
    $routeProvider.
        when('/home', {templateUrl: 'assets/home.html',   controller: HomeCtrl}).
        when('/projects', {templateUrl: 'assets/project.html', controller: ProjectCtrl}).
        when('/site', {templateUrl: 'assets/site.html', controller: SiteCtrl}).
        //when('/phones/:phoneId', {templateUrl: 'partials/phone-detail.html', controller: PhoneDetailCtrl}).
        otherwise({redirectTo: '/home'});
}]);