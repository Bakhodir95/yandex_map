import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:yandex_map/services/location_service.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late YandexMapController mapController;
  List<PlacemarkMapObject> suggetions = [];
  Future<SuggestSessionResult> _suggest(String text) async {
    final resultWithSession = await YandexSuggest.getSuggestions(
      text: _textController.text,
      boundingBox: const BoundingBox(
        northEast: Point(latitude: 56.0421, longitude: 38.0284),
        southWest: Point(latitude: 55.5143, longitude: 37.24841),
      ),
      suggestOptions: const SuggestOptions(
        suggestType: SuggestType.geo,
        suggestWords: true,
        userPosition: Point(latitude: 56.0321, longitude: 38),
      ),
    );

    return await resultWithSession.$2;
  }

  List<MapObject>? polylines;
  final _textController = TextEditingController();
//? Taking positions
  Point myCurrentLocation = const Point(
    latitude: 41.2856806,
    longitude: 69.9034646,
  );

  Point najotTalim = const Point(
    latitude: 41.2856806,
    longitude: 69.2034646,
  );
//! starting from entered location
  void onMapCreated(YandexMapController controller) {
    mapController = controller;
    mapController.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: najotTalim, zoom: 15, azimuth: 1, tilt: 0),
      ),
    );
    setState(() {});
  }

//! setting position of camera

  MapType currentMapType = MapType.vector;
  List<MapType> mapTypes = [
    MapType.map,
    MapType.none,
    MapType.vector,
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: PopupMenuButton<MapType>(
            onSelected: (result) {
              currentMapType = result;
              setState(() {});
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<MapType>>[
              PopupMenuItem<MapType>(
                value: mapTypes[0],
                child: const Text('Map'),
              ),
              PopupMenuItem<MapType>(
                value: mapTypes[1],
                child: const Text('None'),
              ),
              PopupMenuItem<MapType>(
                value: mapTypes[2],
                child: const Text('Vector'),
              ),
            ],
          ),
          backgroundColor: Colors.amber,
          title: const Text("Yandex Map"),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () async {
                await mapController.getUserCameraPosition();
                mapController.moveCamera(
                  CameraUpdate.zoomOut(),
                );
              },
              icon: const Icon(Icons.remove_circle),
            ),
            IconButton(
              onPressed: () {
                mapController.moveCamera(
                  CameraUpdate.zoomIn(),
                );
              },
              icon: const Icon(Icons.add_circle),
            ),
          ],
        ),
        body: Stack(
          children: [
            YandexMap(
              onMapLongTap: (argument) async {
                polylines =
                    await YandexMapService.getDirection(najotTalim, argument);
                myCurrentLocation = argument;
                setState(() {});
              },
              onMapCreated: onMapCreated,
              mapType: currentMapType,
              mapObjects: [
                PlacemarkMapObject(
                  mapId: const MapObjectId("najot ta'lim"),
                  point: najotTalim,
                  icon: PlacemarkIcon.single(
                    PlacemarkIconStyle(
                      scale: 0.4,
                      image:
                          BitmapDescriptor.fromAssetImage("images/image.png"),
                    ),
                  ),
                ),
                // PlacemarkMapObject(
                //   mapId: const MapObjectId("hozirgi manzil"),
                //   point: myCurrentLocation,
                //   icon: PlacemarkIcon.single(
                //     PlacemarkIconStyle(
                //       scale: 0.4,
                //       image:
                //           BitmapDescriptor.fromAssetImage("images/image.png"),
                //     ),
                //   ),
                // ),
                ...?polylines,
                ...suggetions,
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Align(
                  alignment: Alignment.topCenter,
                  child: TextField(
                    onTap: suggetions.clear,
                    controller: _textController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: const OutlineInputBorder(),
                      hintText: 'Search places...',
                      suffixIcon: IconButton(
                          onPressed: () async {
                            SuggestSessionResult datas =
                                await _suggest("value");
                            print("Salom Azamat ${datas.items!.length}");
                            if (datas.items != null) {
                              datas.items!.forEach(
                                (value) {
                                  if (value.center != null) {
                                    suggetions.add(
                                      PlacemarkMapObject(
                                        text: PlacemarkText(
                                            text: value.displayText,
                                            style: PlacemarkTextStyle()),
                                        mapId:
                                            MapObjectId(UniqueKey().toString()),
                                        point: value.center!,
                                        icon: PlacemarkIcon.single(
                                          PlacemarkIconStyle(
                                            scale: 0.4,
                                            image:
                                                BitmapDescriptor.fromAssetImage(
                                                    "images/image.png"),
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                },
                              );
                            }
                            setState(() {});
                            print("bahodir aka" + suggetions.length.toString());
                          },
                          icon: const Icon(Icons.search)),
                    ),
                  )),
            ),
          ],
        ));
  }
}
