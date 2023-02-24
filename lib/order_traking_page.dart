import 'dart:async';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'constants.dart';

class OrderTrackingPage extends StatefulWidget {
  const OrderTrackingPage({Key? key}) : super(key: key);

  @override
  State<OrderTrackingPage> createState() => OrderTrackingPageState();
}

class OrderTrackingPageState extends State<OrderTrackingPage> {
  final Completer<GoogleMapController> _controller = Completer();

  CustomInfoWindowController _customInfoWindowController =
      CustomInfoWindowController();

  static const LatLng sourceLocation = LatLng(37.4227, -122.084);
  static const LatLng destination = LatLng(37.411, -122.072);

  List<LatLng> polylineCoordinates = [];
  LocationData? currentLocation;

  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;

  void getCurrentLocation() async {
    Location location = Location();

    location.getLocation().then((value) {
      currentLocation = value;
    });

    GoogleMapController googleMapController = await _controller.future;

    location.onLocationChanged.listen((newLoc) {
      currentLocation = newLoc;

      googleMapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
              zoom: 16.2,
              target: LatLng(newLoc!.latitude!, newLoc!.longitude!))));
      setState(() {});
    });
  }

  void getPolyPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      google_api_key, // Your Google Map Key
      PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
      PointLatLng(destination.latitude, destination.longitude),
    );
    if (result.points.isNotEmpty) {
      result.points.forEach(
        (PointLatLng point) => polylineCoordinates.add(
          LatLng(point.latitude, point.longitude),
        ),
      );
      setState(() {});
    }
  }

  void setCustomMarkerIcon() {
    BitmapDescriptor.fromAssetImage(ImageConfiguration.empty, 'assets/bbb.png')
        .then((icon) {
      sourceIcon = icon;
    });

    BitmapDescriptor.fromAssetImage(ImageConfiguration.empty, 'assets/ccc.png')
        .then((icon) {
      destinationIcon = icon;
    });

    BitmapDescriptor.fromAssetImage(ImageConfiguration.empty, 'assets/aaa.png')
        .then((icon) {
      currentLocationIcon = icon;
    });
  }

  @override
  void initState() {
    getPolyPoints();
    getCurrentLocation();
    setCustomMarkerIcon();
    super.initState();
  }

  @override
  void dispose() {
    _customInfoWindowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Live View",
          ),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            currentLocation == null
                ? const Center(child: Text("Bruh, enable location!"))
                : GoogleMap(
                    initialCameraPosition: CameraPosition(
                        target: LatLng(currentLocation!.latitude!,
                            currentLocation!.longitude!),
                        zoom: 14.5),
                    polylines: {
                      Polyline(
                        polylineId: PolylineId('route'),
                        points: polylineCoordinates,
                        // color: const Color(0xFF7B61FF),
                        color: Colors.blueAccent,
                        width: 5,
                      )
                    },
                    markers: {
                      Marker(
                          markerId: MarkerId('CurrentLocation'),
                          icon: currentLocationIcon,
                          position: LatLng(currentLocation!.latitude!,
                              currentLocation!.longitude!),
                          onTap: () {
                            _customInfoWindowController.addInfoWindow!(
                                Container(
                                    decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.6),
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(color: Colors.blue)),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: ListTile(
                                            leading: Icon(Icons.timer, color: Colors.orange, size: 30,),
                                            title: Text(
                                                "Estimated Time of Delivery: 2h 20m",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 18
                                                )),
                                          ),
                                        ),
                                        Expanded(
                                          child: ListTile(
                                            leading:
                                                Icon(Icons.water_drop_rounded, color: Colors.blue,size: 30),
                                            title: Text("Fuel: 80%",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 18
                                                )),
                                          ),
                                        ),
                                        Expanded(
                                          child: ListTile(
                                            leading: Icon(Icons.tire_repair, color: Colors.green, size: 30) ,
                                            title: Text(
                                                "Maintenance Status: Low Risk",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 18
                                            ),),
                                          ),
                                        ),
                                      ],
                                    )),
                                LatLng(currentLocation!.latitude!,
                                    currentLocation!.longitude!));
                          }),
                      Marker(
                        icon: sourceIcon,
                        markerId: MarkerId('Source'),
                        position: sourceLocation,
                      ),
                      Marker(
                        icon: destinationIcon,
                        markerId: MarkerId('Destination'),
                        position: destination,
                      )
                    },
                    onTap: (position) {
                      _customInfoWindowController.hideInfoWindow!();
                    },
                    onCameraMove: (position) {
                      _customInfoWindowController.onCameraMove!();
                    },
                    onMapCreated: (mapController) {
                      _controller.complete(mapController);
                      _customInfoWindowController.googleMapController =
                          mapController;
                    },
                  ),
            CustomInfoWindow(
                width: MediaQuery.of(context).size.width * 0.6,
                height: MediaQuery.of(context).size.height * 0.24,
                offset: 50,
                controller: _customInfoWindowController),
          ],
        ));
  }
}
