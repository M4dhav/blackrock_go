import 'dart:convert';
import 'dart:developer';
import 'package:blackrock_go/controllers/event_controller.dart';
import 'package:blackrock_go/controllers/mapbox_map_controller.dart';
import 'package:blackrock_go/models/const_model.dart';
import 'package:blackrock_go/models/event_model.dart';
import 'package:blackrock_go/views/widgets/drawer_widget.dart';
import 'package:blackrock_go/views/widgets/appbar_widget.dart';
import 'package:blackrock_go/views/widgets/event_widget.dart';
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
  final EventController eventController = Get.find();
  final MapboxMapController mapboxMapController = Get.find();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> onStyleLoaded(StyleLoadedEventData data) async {
    await mapboxMapController.addEventsModelLayer(eventController.events);
    mapboxMapController.addEventsModelLayerInteractions(
        eventController, context);
    log('style loaded');
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
          onMapCreated: mapboxMapController.onMapCreated,
          onStyleLoadedListener: onStyleLoaded,
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
