import 'dart:convert';
import 'dart:developer';
import 'package:blackrock_go/controllers/event_controller.dart';
import 'package:blackrock_go/models/const_model.dart';
import 'package:blackrock_go/models/event_model.dart';
import 'package:blackrock_go/views/widgets/drawer_widget.dart';
import 'package:blackrock_go/views/widgets/appbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mb;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class MapHomePage extends StatefulWidget {
  const MapHomePage({super.key});

  @override
  State<MapHomePage> createState() => _MapHomePageState();
}

class _MapHomePageState extends State<MapHomePage> {
  mb.MapboxMap? mapboxMap;
  final EventController eventController = Get.find();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> addModelLayer(List<EventModel> events) async {
    List<Feature> features = [];
    features.add(Feature(
        id: 0,
        geometry: Point(
            coordinates: mb.Position(-119.20309919712876, 40.786984204692935)),
        properties: {
          'name': 'Burning Man',
          'location': 'Centrepoint',
          'index': 0
        }));
    for (EventModel event in events) {
      features.add(Feature(
          id: events.indexOf(event),
          geometry:
              Point(coordinates: mb.Position(event.longitude, event.latitude)),
          properties: {
            'name': event.eventName,
            'location': event.locationName,
            'index': events.indexOf(event)
          }));
    }

    FeatureCollection featureCollection = FeatureCollection(features: features);
    if (mapboxMap == null) {
      throw Exception("MapboxMap is not ready yet");
    }
    await mapboxMap?.style.addSource(
        GeoJsonSource(id: "events", data: json.encode(featureCollection)));

    await mapboxMap?.style.addStyleModel("eventsModel",
        "https://github.com/M4dhav/alpha-go/raw/demo-v1.3.1/assets/bitcoin/main.glb");

    var modelLayer = ModelLayer(id: "eventsLayer", sourceId: "events");
    modelLayer.modelId = "eventsModel";
    modelLayer.modelScale = [10, 10, 10];
    modelLayer.modelType = ModelType.COMMON_3D;
    await mapboxMap?.style.addLayer(modelLayer);
    await mapboxMap?.style.addLayer(
      SymbolLayer(
        id: 'event-labels',
        sourceId: 'events',
        textFieldExpression: [
          'get',
          'name'
        ], // This will use the 'name' property for the label
        textSize: 14,
        textHaloColorExpression: [0xFFFFFFFF], // White halo
        textHaloWidthExpression: [2.0],
        symbolZOffset: 10.0,
        textOcclusionOpacity: 1.0,

        // textColor: Colors.red.hashCode,
        // textColorExpression: [Colors.red.hashCode, Colors.red.hashCode]
        // You can add more styling properties as needed
      ),
    );

    log('added modelLayer');
  }

  void _onMapCreated(mb.MapboxMap mapboxMap) {
    this.mapboxMap = mapboxMap;
    mapboxMap.location.updateSettings(mb.LocationComponentSettings(
        enabled: true,
        puckBearing: mb.PuckBearing.HEADING,
        puckBearingEnabled: true,
        locationPuck: mb.LocationPuck(
            locationPuck3D: mb.LocationPuck3D(
          modelUri:
              "https://github.com/M4dhav/alpha-go/raw/dev/assets/pointer.glb",
          modelScale: [2, 2, 2],
        ))));
    log('puck added');
  }

  Future<void> _onStyleLoaded(StyleLoadedEventData data) async {
    await addModelLayer(eventController.events);
    log('style loaded');
    //TODO: Add interaction
    // mapboxMap!.addInteraction(
    //     TapInteraction(
    //       FeaturesetDescriptor(
    //         layerId: "eventsLayer",
    //       ),
    //       (feature, mapContext) async {
    //         EventModel event =
    //             eventController.events[feature.properties['index'] as int];

    //         if (mounted) {
    //           showDialog(
    //             context: context,
    //             builder: (context) => EventWidget(
    //               event: event,
    //               hostName: event.hostName,
    //             ),
    //           );
    //         }
    //       },
    //       stopPropagation: false,
    //     ),
    //     interactionID: "eventTapInteraction");

    log('loaded interactions');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/bg.jpg"), fit: BoxFit.cover)),
      child: Scaffold(
        key: _scaffoldKey,
        drawer: const CustomDrawer(),
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        appBar: CustomAppBar(
            leadingWidget: Padding(
              padding: EdgeInsets.only(left: 3.w),
              child: Image.asset(
                'assets/blackrock_logo_transparent.png',
                fit: BoxFit.contain,
              ),
            ),
            actionWidgets: Row(
              children: [
                InkWell(
                  onTap: () {
                    context.push("/search");
                  },
                  child: Container(
                    width: 50.w,
                    padding: EdgeInsets.only(bottom: 1.h, top: 1.h, right: 2.w),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Constants.primaryGold,
                          width: 0.4.sp,
                        ),
                      ),
                    ),
                    child: Text(
                      'Search',
                      style: TextStyle(
                        color: Constants.primaryGold,
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    right: 3.w,
                  ),
                  child: Center(
                    child: IconButton(
                        onPressed: () {
                          _scaffoldKey.currentState?.openDrawer();
                          log('opening');
                        },
                        icon: Icon(
                          Icons.menu,
                          color: Constants.primaryGold,
                          size: 29.sp,
                        )),
                  ),
                )
              ],
            )),
        body: mb.MapWidget(
          mapOptions: mb.MapOptions(
            pixelRatio: 1.0,
            orientation: mb.NorthOrientation.UPWARDS,
          ),
          key: const ValueKey("mapWidget"),
          onMapCreated: _onMapCreated,
          onStyleLoadedListener: _onStyleLoaded,
          styleUri: Constants.mapboxStyleUrl,
          cameraOptions: mb.CameraOptions(
              bearing: 43.7,
              center: mb.Point(
                  coordinates: mb.Position(
                -119.2113039478112,
                40.78114827014911,
              )),
              zoom: 13.84),
        ),
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () {
        //     determinePosition().then((value) {
        //       setState(() async {
        //         await mapboxMap?.flyTo(
        //             mb.CameraOptions(
        //                 pitch: 90,
        //                 center: mb.Point(
        //                     coordinates:
        //                         mb.Position(value.longitude, value.latitude)),
        //                 zoom: 12.0),
        //             mb.MapAnimationOptions());
        //       });
        //     });
        //   },
        //   child: const Icon(Icons.my_location),
        // ),
        // floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
      ),
    );
  }
}
