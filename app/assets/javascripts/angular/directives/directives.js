(function () {
    var bawds = angular.module('bawApp.directives', []);

    bawds.directive('addRedBox', function () {
        return function (scope, element, attrs) {
            element.append("<div style='background-color: red; height: 100px; width: 100px'></div>");
        }
    });

    bawds.directive('bawRecordInformation', function () {

        return {
            restrict: 'AE',
            scope: false,
            /* priority: ???  */
//            controller: 'RecordInformationCtrl',
            /* require: ??? */
            /*template: "<div></div>",*/
            templateUrl: "/assets/record_information.html",
            replace: false,
            /*compile: function(tElement, tAttrs, transclude) {

             },*/
            link: function (scope, iElement, iAttrs, controller) {
                scope.name = scope[iAttrs.ngModel];


            }

        }
    });

    bawds.directive('bawDebugInfo', function () {
        return {
            restrict: 'AE',
            replace: true,
            template: '<div><a href ng-click="showOrHideDebugInfo= !showOrHideDebugInfo">Debug info {{showOrHideDebugInfo}}</a><pre ui-toggle="showOrHideDebugInfo" class="ui-hide"  ng-bind="print()"></pre></div>',
            link: function (scope, element, attrs) {
                if (!scope.print) {
                    //console.warn("baw-debug-info missing parent scope, no print function");
                    scope.print = bawApp.print;
                }
            }
        }
    });

    bawds.directive('bawJsonBinding', function () {
        return {
            restrict: 'A',
            require: 'ngModel',
            link: function (scope, element, attr, ngModel) {

                function catchParseErrors(viewValue){
                    try{
                        var result = angular.fromJson(viewValue);
                    }catch(e){
                        ngModel.$setValidity('bawJsonBinding',false);
                        return '';
                    }
                    ngModel.$setValidity('bawJsonBinding',true);
                    return result;
                }

                ngModel.$parsers.push(catchParseErrors);
                ngModel.$formatters.push(angular.toJson)
            }
        };
    });

    // ensures formatters are run on input blur
    bawds.directive('renderOnBlur', function() {
        return {
            require: 'ngModel',
            restrict: 'A',
            link: function(scope, elm, attrs, ctrl) {
                elm.bind('blur', function() {
                    var viewValue = ctrl.$modelValue;
                    for (var i in ctrl.$formatters) {
                        viewValue = ctrl.$formatters[i](viewValue);
                    }
                    ctrl.$viewValue = viewValue;
                    ctrl.$render();
                });
            }
        };
    });


    bawds.directive('isGuid', function () {
        return {

            require: 'ngModel',
            link: function (scope, elm, attrs, ctrl) {
                var isList = typeof attrs.ngList !== "undefined";

                // push rather than unshift... we want to test last
                ctrl.$parsers.push(function (viewValue) {
                    var valid = true;
                    if (isList) {
                        for (var i = 0; i < viewValue.length && valid; i++) {
                            valid = GUID_REGEXP.test(viewValue[i]);
                        }
                    }
                    else {
                        valid = GUID_REGEXP.test(viewValue);
                    }

                    if (valid) {
                        // it is valid
                        ctrl.$setValidity('isGuid', true);
                        return viewValue;
                    } else {
                        // it is invalid, return undefined (no model update)
                        ctrl.$setValidity('isGuid', false);
                        return undefined;
                    }
                });
            }
        };
    });

    // implements infinite scrolling
    // http://jsfiddle.net/vojtajina/U7Bz9/
    bawds.directive('whenScrolled', function() {
        return function(scope, elm, attr) {
            var raw = elm[0];

            elm.bind('scroll', function() {
                console.log('scrolled');
                if (raw.scrollTop + raw.offsetHeight >= raw.scrollHeight) {
                    scope.$apply(attr.whenScrolled);
                }
            });
        };
    });


    bawds.directive('bawAnnotationViewer', function () {

        var converters = function () {
            // TODO: these are stubs and will need to be refactored

            // constants go here

            return {
                pixelsToSeconds: function pixelsToSeconds(value) {
                    return value;
                },
                pixelsToHertz: function pixelsToHertz(value) {
                    return value;
                },
                secondsToPixels: function secondsToPixels(value) {
                    return value;
                },
                hertzToPixels: function hertzToPixels(value) {
                    return value;
                }
            };
        };

        function resizeOrMove(audioEvent, box) {

            if (audioEvent.__temporaryId__ === box.id) {
                audioEvent.startTimeSeconds =  box.left || 0;
                audioEvent.highFrequencyHertz = box.top || 0;
                //b.width = box.width;
                //b.height = box.height;
                audioEvent.endTimeSeconds = (audioEvent.startTimeSeconds + box.width) || 0;
                audioEvent.lowFrequencyHertz = (audioEvent.highFrequencyHertz + box.height) || 0;
            }
            else {
                console.error("Box ids do not match on resizing  or move event", audioEvent.__temporaryId__ , box.id);
            }
        }
        function resizeOrMoveWithApply(scope, audioEvent, box) {
            scope.$apply(function() {
                resizeOrMove(audioEvent, box);
            })
        }

        function touchUpdatedField(audioEvent) {
            audioEvent.updatedAt = new Date();
        }

        function create(simpleBox, audioRecordingId) {
            var now = new Date();
            var audioEvent = {
                __temporaryId__: simpleBox.id,
                audioRecordingId: audioRecordingId,

                createdAt: now,
                updatedAt: now,

                endTimeSeconds: 0.0,
                highFrequencyHertz: 0.0,
                isReference: false,
                lowFrequencyHertz: 0.0,
                startTimeSeconds: 0.0,
                audioEventTags: []
            };

            resizeOrMove(audioEvent, simpleBox);
            touchUpdatedField(audioEvent);

            return audioEvent;
        }

        /**
         * Create an watcher for an audio event model.
         * The purpose is to allow for reverse binding from model -> drawabox
         * NB: interestingly, these watchers are bound to array indexes... not the objects in them.
         *  this means the object is not coupled to the watcher and is not affected by any operation on it.
         * @param scope
         * @param array
         * @param index
         * @param drawaboxInstance
         */
        function registerWatcher(scope, array, index, drawaboxInstance) {

            // create the watcher
            var watcherFunc = function() {
                return array[index];
            };

            // create the listener - the actual callback
            var listenerFunc = function(value) {
                console.log("audioEvent watcher fired");

                // TODO: SET UP CONVERSIONS HERE
                var top = value.highFrequencyHertz,
                    left = value.startTimeSeconds,
                    width = value.endTimeSeconds - value.startTimeSeconds,
                    height = value.highFrequencyHertz - value.lowFrequencyHertz;

                drawaboxInstance.drawabox('setBox', value.__temporaryId__, top, left, height, width, undefined);
            };

            // tag both for easy removal later
            var tag = "index" + index.toString()
            watcherFunc.__drawaboxWatcherForAudioEvent = tag;
            listenerFunc.__drawaboxWatcherForAudioEvent = tag;

            // don't know if I need deregisterer or not - use this to stop listening...
            // --
            // note the last argument sets up the watcher for compare equality (not reference).
            // this may cause memory / performance issues if the model gets too big later on
            var deregisterer = scope.$watch(watcherFunc, listenerFunc, true)
        }

        return {
            restrict: 'AE',
            scope: {
                model: '=model'
            },
            controller: AnnotationViewerCtrl,
            require: '', // ngModel?
            templateUrl: '/assets/annotation_viewer.html',
//            compile: function(element, attributes, transclude)  {
//                // transform DOM
//            },
            link: function (scope, element, attributes, controller) {

                var $element = $(element);

                // assign a unique id to scope
                scope.id = Number.Unique();

                scope.$canvas = $element.find(".annotation-viewer img + div").first();

                // init drawabox
                scope.model.audioEvents = scope.model.audioEvents || [];
                scope.model.selectedAudioEvents = scope.model.selectedAudioEvents || [];


                scope.$canvas.drawabox({
                    "selectionCallbackTrigger": "mousedown",
                    "newBox": function (element, newBox) {
                        var newAudioEvent = create(newBox, "a dummy id!");


                        scope.$apply(function() {
                            scope.model.audioEvents.push( newAudioEvent);

                            var annotationViewerIndex = scope.model.audioEvents.length - 1;
                            element[0].annotationViewerIndex  = annotationViewerIndex;

                            // register for reverse binding
                            registerWatcher(scope, scope.model.audioEvents, annotationViewerIndex, scope.$canvas);

                            console.log("newBox", newBox, newAudioEvent);
                        });
                    },
                    "boxSelected": function (element, selectedBox) {
                        console.log("boxSelected", selectedBox);

                        // support for multiple selections - remove the clear
                        scope.$apply(function() {
                            scope.model.selectedAudioEvents.length = 0;
                            scope.model.selectedAudioEvents.push(scope.model.audioEvents[element[0].annotationViewerIndex]);
                        });
                    },
                    "boxResizing": function (element, box) {
                        console.log("boxResizing");
                        resizeOrMoveWithApply(scope, scope.model.audioEvents[element[0].annotationViewerIndex], box);

                    },
                    "boxResized": function (element, box) {
                        console.log("boxResized");
                        resizeOrMoveWithApply(scope, scope.model.audioEvents[element[0].annotationViewerIndex], box);
                    },
                    "boxMoving": function (element, box) {
                        console.log("boxMoving");
                        resizeOrMoveWithApply(scope, scope.model.audioEvents[element[0].annotationViewerIndex], box);
                    },
                    "boxMoved": function (element, box) {
                        console.log("boxMoved");
                        resizeOrMoveWithApply(scope, scope.model.audioEvents[element[0].annotationViewerIndex], box);
                    },
                    "boxDeleted": function (element, deletedBox) {
                        console.log("boxDeleted");

                        scope.$apply(function(){
                            // TODO: i'm not sure how I should handle 'deleted' items yet
                            var itemToDelete = scope.model.audioEvents[element[0].annotationViewerIndex];
                            itemToDelete.deletedAt = (new Date());

                            if (scope.model.selectedAudioEvents.length > 0) {
                                var index = scope.model.selectedAudioEvents.indexOf(itemToDelete);

                                if (index >= 0) {
                                    scope.model.selectedAudioEvents.splice(index, 1);
                                }
                            }
                        });
                    }
                });
            }
        }
    });


})();

//bawApp.directive('nsDsFade', function() {
//    return function(scope, element, attrs) {
//        element.css('display', 'none');
//        scope.$watch(attrs.ngDsFade, function(value) {
//           if (value) {
//               element.fadeIn(200);
//           }
//           else {
//               element.fadeOut(100);
//           }
//        });
//    }
//
//});
//

