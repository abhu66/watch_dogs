import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:watch_dogs/location_service.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider<UserLocation>(
        builder: (contexts) => LocationService().locationStream,
    child : MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Watch Dogs'),
    ),
    );
  }
}



class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Completer<GoogleMapController> _mapController = Completer();
  Location location;
  LatLng _currentPosition;
  UserLocation _userLocation;
  Map<String, double> userLocation;
  final Map<String, Marker> _markers = {};
  // for my custom marker pins
  BitmapDescriptor sourceIcon;
  // the user's initial location and current location
// as it moves
  LocationData currentLocation;



  @override void initState() {
    // TODO: implement initState
    super.initState();
    location = new Location();
    location.onLocationChanged().listen((value) {
      setState(() {
        setSourceAndDestinationIcons();
        _currentPosition = LatLng(value.latitude,value.longitude);
        final marker = Marker(
          markerId: MarkerId(
              "${_currentPosition.latitude}, ${_currentPosition.longitude}"),
          icon: sourceIcon,
          position: _currentPosition,
          infoWindow: InfoWindow(title: "Abu Khoerul Iskandar Ali "),
        );
        _markers["Current Location"] = marker;
      });
    });
  }

  void animateCamera(LatLng currentLocation) async{
    final GoogleMapController controller = await _mapController.future;
    CameraPosition dPosition = CameraPosition(
      zoom: 15,
      tilt: 15,
      bearing: 15,
      target: LatLng(currentLocation.latitude,
          currentLocation.longitude),
    );
    controller.animateCamera(CameraUpdate.newCameraPosition(dPosition));
  }


  @override
  Widget build(BuildContext context) {

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );


    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: buildGooglMap(context),
    );
  }

  Widget buildGooglMap(BuildContext context){
    _userLocation = Provider.of(context);
    return GoogleMap(
      myLocationEnabled: true,
      compassEnabled: true,
      mapType: MapType.normal,
      tiltGesturesEnabled: false,
       initialCameraPosition: CameraPosition(
          target: LatLng(_userLocation.latitude,_userLocation.longitude),
          zoom: 15,
          tilt: 15,
          bearing: 15,
        ),
        onMapCreated: (GoogleMapController controller){
          _mapController.complete(controller);
          showPinOnMap();
        },
        markers: _markers.values.toSet(),
      );
  }

  void showPinOnMap(){
    // get a LatLng for the source location
    // from the LocationData currentLocation object
    var pinPosition = LatLng(currentLocation.latitude,
        currentLocation.longitude);

    _markers.clear();
    final marker = Marker(
      markerId: MarkerId(
          "sourcePin"),
      icon: sourceIcon,
      position: pinPosition,
//      infoWindow: InfoWindow(title: "Abu Khoerul Iskandar Ali "),
    );
    _markers["Current Location"] = marker;
  }

  void setSourceAndDestinationIcons() async {
    sourceIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), "assets/user_pin.png");
  }

}
