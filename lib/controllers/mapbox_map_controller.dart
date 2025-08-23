import 'dart:convert';
import 'dart:developer';

import 'package:blackrock_go/controllers/event_controller.dart';
import 'package:blackrock_go/controllers/meshtastic_node_controller.dart';
import 'package:blackrock_go/models/event_model.dart';
import 'package:blackrock_go/views/widgets/event_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:meshtastic_flutter/meshtastic_flutter.dart' hide Position;

class MapboxMapController {
  MapboxMap? mapboxMap;

  void onMapCreated(MapboxMap mapboxMap) {
    this.mapboxMap = mapboxMap;
    mapboxMap.location.updateSettings(LocationComponentSettings(
        enabled: true,
        puckBearing: PuckBearing.HEADING,
        puckBearingEnabled: true,
        locationPuck: LocationPuck(
            locationPuck3D: LocationPuck3D(
          modelUri:
              "https://github.com/M4dhav/alpha-go/raw/dev/assets/pointer.glb",
          modelScale: [2, 2, 2],
        ))));
    log('puck added');
  }

  Future<void> addEventsModelLayer(List<EventModel> events) async {
    List<Feature> features = [];
    features.add(Feature(
        id: 0,
        geometry: Point(
            coordinates: Position(-119.20309919712876, 40.786984204692935)),
        properties: {
          'name': 'Burning Man',
          'location': 'Centrepoint',
          'index': 0
        }));
    for (EventModel event in events) {
      features.add(Feature(
          id: events.indexOf(event) + 1,
          geometry:
              Point(coordinates: Position(event.longitude, event.latitude)),
          properties: {
            'name': event.eventName,
            'location': event.locationName,
            'index': events.indexOf(event)
          }));
    }

    FeatureCollection featureCollection = FeatureCollection(features: features);

    await mapboxMap?.style.addSource(
        GeoJsonSource(id: "events", data: json.encode(featureCollection)));

    await mapboxMap?.style.addStyleModel("eventsModel",
        "https://github.com/M4dhav/alpha-go/raw/demo-v1.3.1/assets/bitcoin/main.glb");

    var modelLayer = ModelLayer(id: "eventsLayer", sourceId: "events");
    modelLayer.modelId = "eventsModel";
    modelLayer.modelScale = [10, 10, 10];
    modelLayer.modelType = ModelType.COMMON_3D;
    await mapboxMap?.style.addLayer(modelLayer);
    // await mapboxMap?.style.addLayer(
    //   SymbolLayer(
    //     id: 'event-labels',
    //     sourceId: 'eventsLayer',
    //     textFieldExpression: [
    //       'get',
    //       'name'
    //     ], // This will use the 'name' property for the label
    //     textSize: 14,
    //     textHaloColorExpression: [0xFFFFFFFF], // White halo
    //     textHaloWidthExpression: [2.0],
    //     symbolZOffset: 10.0,
    //     textOcclusionOpacity: 1.0,

    // textColor: Colors.red.hashCode,
    // textColorExpression: [Colors.red.hashCode, Colors.red.hashCode]
    // You can add more styling properties as needed
    //   ),
    // );

    log('added modelLayer');

    final meshtasticNodeController = Get.find<MeshtasticNodeController>();

    if (meshtasticNodeController.connectionStatus.value.state ==
        MeshtasticConnectionState.connected) {
      addNodesModelLayer(
          meshtasticNodeController.client.nodes.values.where((node) {
        return node.userId != meshtasticNodeController.client.localUser?.id;
      }).toList());
    }
  }

  void addEventsModelLayerInteractions(
      EventController eventController, BuildContext context) {
    mapboxMap?.addInteraction(
        TapInteraction(
          FeaturesetDescriptor(
            layerId: "eventsLayer",
          ),
          (feature, mapContext) async {
            log('Feature tapped: ${feature.properties}');
            EventModel event =
                eventController.events[feature.properties['index'] as int];

            showDialog(
              context: context,
              builder: (context) => EventWidget(
                event: event,
              ),
            );
          },
          stopPropagation: true,
        ),
        interactionID: "eventTapInteraction");

    log('loaded interactions');
  }

  Future<void> addNodesModelLayer(List<NodeInfoWrapper> nodes) async {
    List<Feature> features = [];

    for (NodeInfoWrapper node in nodes) {
      log('Adding node: ${node.displayName} at (${node.latitude}, ${node.longitude})');
      features.add(Feature(
          id: nodes.indexOf(node),
          geometry: Point(
              coordinates: Position(node.longitude ?? 0, node.latitude ?? 0)),
          properties: {
            'name': node.displayName,
            'longName': node.longName,
            'index': nodes.indexOf(node)
          }));
    }

    FeatureCollection featureCollection = FeatureCollection(features: features);

    await mapboxMap?.style.addSource(
        GeoJsonSource(id: "nodes", data: json.encode(featureCollection)));

    await mapboxMap?.style.addStyleModel("nodesModel",
        "https://github.com/M4dhav/alpha-go/raw/dev/assets/pointer.glb");

    var modelLayer = ModelLayer(id: "nodesLayer", sourceId: "nodes");
    modelLayer.modelId = "nodesModel";
    modelLayer.modelScale = [2, 2, 2];
    modelLayer.modelType = ModelType.COMMON_3D;
    await mapboxMap?.style.addLayer(modelLayer);

    log('added nodesLayer');
  }
}
