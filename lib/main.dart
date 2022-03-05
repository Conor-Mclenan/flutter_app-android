import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_gradient_colors/flutter_gradient_colors.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'dart:async';
import 'dart:typed_data';    import 'dart:math' show cos, sqrt, asin;
import 'GlobalVariables.dart';


const pageHpercent=0.001228;
void main() {
  runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Page1(),
      ));
}


class Page1 extends StatefulWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blueGrey[900],
      ),
    );
  }
  _Page1State createState() => _Page1State();

  }

class _Page1State extends State<Page1>{
  double viewPortFraction = 1;
  bool selected = false;
  var DistanceString;

  double calculateDistance(lat1, lon1, lat2, lon2){
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p)/2 +
        c(lat1 * p) * c(lat2 * p) *
            (1 - c((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a));
  }

  PageController pageController;
  PageController pagecontroller;
  double totalDistance = 0;
  double page = 1.0;
  int currentPage = 0;
  double scale;
  double lastsaved;
  Location location = new Location();

  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _locationData;

  @override
  void initState() {
    pageController =
        PageController(initialPage: currentPage, viewportFraction: viewPortFraction);
    pagecontroller =
        PageController(initialPage: 1, viewportFraction: viewPortFraction);
    getLoc();
    super.initState();
  }


  getLoc() async {
    _serviceEnabled = await location.serviceEnabled(); //make sure the app can see the location
    if (!_serviceEnabled) {                           // if it cant
      _serviceEnabled = await location.requestService();   //request permission to see the phones location
      if (!_serviceEnabled) {   // if  it doesn't work
        return;               //don't do the rest
      }
    }

    _permissionGranted = await location.hasPermission(); // check if permission granted
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    location.onLocationChanged.listen((LocationData currentLocation) async{ // get current location in lat and long
      _locationData = await location.getLocation(); //make location variable equal to location

      final split = Globals.dat.split(","); //separate the incoming data at the comma
      final Map<int, String> values = {
        for (int i = 0; i < 2; i++) // get a value for both sides of the data
          i: split[i]
      };
      print(values);  // {0: long, 1:  lat}

      final value1 = values[0]; //transfer to own variables
      final value2 = values[1];

      var long2 = double.parse(value2); //change values from string to double (number with decimals)
      var lat2 = double.parse(value1);


      List<dynamic> data = [ //list out data and match two varying lats and longs
          {
            "lat":  _locationData.latitude,
            "lng": _locationData.longitude
          },{
            "lat": lat2,
            "lng": long2,
          }
        ];


        for(var i = 0; i < data.length-1; i++){
          totalDistance = (calculateDistance(data[i]["lat"], data[i]["lng"], data[i+1]["lat"], data[i+1]["lng"]))*1000; //does math to find distance between data
        }
        setState(() {
          DistanceString = totalDistance.toStringAsPrecision(3); //puts distance into variable to use elsewhere in app
        });
      print(totalDistance);
      });

    }


  @override
  Widget build(BuildContext context){
    var ScrW = MediaQuery.of(context).size.width;
    var ScrH = MediaQuery.of(context).size.height;
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: GradientColors.sunrise,)),
    child: Scaffold(
        // By defaut, Scaffold background is white
        // Set its value to transparent
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,

          appBar: PreferredSize(
            preferredSize: Size.fromHeight((70*(1-page)+50)),


    child: Container(
    child: Align(alignment: Alignment.centerLeft,
      child: AnimatedCrossFade(
        duration: const Duration(milliseconds: 500),
        firstChild: Column(children:[
      Padding(
      padding: EdgeInsets.only(
        top: ScrH*pageHpercent*42,
      ),
        child: Text('Latest save:',
    style: TextStyle(
    fontSize: ScrH*pageHpercent*22.0,
    fontWeight: FontWeight.bold,
    color: Colors.white))),
        Padding(
            padding: EdgeInsets.only(
              top: ScrH*pageHpercent*6,
              left:35,
            ),
            child:Text('100CM',
          style: TextStyle(
              fontSize: ScrH*pageHpercent*48.0,
              fontWeight: FontWeight.bold,
              color: Colors.white)))]),

      secondChild: Center(
          child:Text('Settings',
          style: TextStyle(
              fontSize: ScrH*pageHpercent*48.0,
              fontWeight: FontWeight.bold,
              color: Colors.white))),

        crossFadeState: page>0.2 ? CrossFadeState.showSecond : CrossFadeState.showFirst,
    )),
    decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30),
              ),
      color: Colors.blueGrey[900],
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.5),
          spreadRadius: 5,
          blurRadius: 7,
          offset: Offset(0, 3), // changes position of shadow
        ),
      ],
    ),

          ),
          ),
          body:
          PageView(
          controller: pagecontroller,
    scrollDirection: Axis.vertical,
    children:<Widget>[
    Page3(),
    NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification notification) {
               if (notification is ScrollUpdateNotification) {
                 setState(() {
                   page = pageController.page;
                 });
               }
             },
            child: PageView(
                controller: pageController,
             children: <Widget> [
      Column(children: <Widget>[
        SizedBox(height:ScrH*0.258 ),//original 210px
        Container(child: Align(alignment: Alignment.bottomRight,
            child: Container(
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.horizontal(
                              left: Radius.circular(30),
                              right: Radius.circular(0))),
                      primary: Colors.blueGrey[900]),
                  onPressed: () {
  },

                  child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                          children: <TextSpan>[
                            TextSpan(text: DistanceString,
                                style: TextStyle(fontSize: ScrH*pageHpercent*100,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromRGBO(245, 130, 27, 1),


                                )),
                            TextSpan(
                                text: 'CM',
                                style: TextStyle(fontSize: ScrH*pageHpercent*70,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromRGBO(245, 130, 27, 1))),
                          ]))),
              width: 400,
              height: ScrH*0.246,))),

        SizedBox(height: ScrH*0.074),
        Container(
            width: 300,
            height: ScrH*0.111,
            decoration: BoxDecoration(
                color: Colors.blueGrey[900],
                borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(60),
                    right: Radius.circular(60)),
                boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              spreadRadius: 3,
              blurRadius: 5,
          offset: Offset(0, 3), // changes position of shadow
        ),
      ],),

        child:Center(
            child:Text('Save Result',
                style: TextStyle(
                    fontSize: ScrH*pageHpercent*30.0,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(245, 130, 27, 1)))
        )),
        SizedBox(height: ScrH*0.037),
        GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => BluetoothApp()));
              setState(() {
                selected = !selected;
              });

            },
            child:
        AnimatedContainer(width: 300,
            height: ScrH*0.111,
            margin: selected ? EdgeInsets.only(top: ScrH*pageHpercent*10,): EdgeInsets.only(top: ScrH*pageHpercent*0,),
          duration: const Duration(seconds: 0),
            decoration: BoxDecoration(
                color: Colors.blueGrey[900],
                borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(60),
                    right: Radius.circular(60)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  spreadRadius: 3,
                  blurRadius: 5,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],),  child:Center(
                child:Text('Bluetooth',
                    style: TextStyle(
                        fontSize: ScrH*pageHpercent*30.0,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(245, 130, 27, 1)))
            )            )),
      ]),





      Page2()
    ])),
    ]),


    bottomNavigationBar: Stack(
          children: <Widget>[
            Container(
              height:ScrH*0.104,
              child: Align(alignment: Alignment.bottomRight,
    child:AnimatedContainer(
      width: (ScrW*page)+0.1,
              height: ScrH*0.104,
              color: Colors.blueGrey[900],
              duration: const Duration(seconds: 0),))),
         Row(children:[
         AnimatedContainer(
           width:(ScrW*0.5),
            height: ScrH*0.104,
                decoration: BoxDecoration(
                  color: page > 0.1 ?  Color.fromRGBO(245, 130, 27, 1) : Color.fromRGBO(245, 144, 27, 0),
                    borderRadius: BorderRadius.only(
                topRight: Radius.circular(60),
        )
        ),
        duration: const Duration(milliseconds: 300),
        child:Center(
            child:Text('Home',
                style: TextStyle(
                    fontSize: ScrH*pageHpercent*27.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white))
        )),
      AnimatedContainer(
        width:(ScrW*0.5),
        height: ScrH*0.104,
        decoration: BoxDecoration(
            color: Colors.blueGrey[900],
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(60),
            )),
        duration: const Duration(seconds: 0),
          child:Center(
              child:Text('Settings',
                  style: TextStyle(
                      fontSize: ScrH*pageHpercent*27.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white))
          )),
         ]),

    ]),
        extendBody: true)
    );
  }

} class Page2 extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
    body:
        Column(children: <Widget>[
       ])
    );
    }
    }

class Page3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var ScrW = MediaQuery.of(context).size.width;
    var ScrH = MediaQuery.of(context).size.height;
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Column( children:<Widget>[ Expanded(child: Center(child: SizedBox(child:Container(
          decoration: BoxDecoration(
              color: Colors.blueGrey[900],
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(30),
            ),
              ))),
    )),
      Container( height:ScrH*0.123,
    color: Colors.white.withOpacity(0),
    ),
]),
    );
  }
}


class BluetoothApp extends StatefulWidget {
  @override
  _BluetoothAppState createState() => _BluetoothAppState();
}

class _BluetoothAppState extends State<BluetoothApp> {
  // Initializing the Bluetooth connection state to be unknown
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  // Initializing a global key, as it would help us in showing a SnackBar later
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  // Get the instance of the Bluetooth
  FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;

  // Track the Bluetooth connection with the remote device
  BluetoothConnection connection;

  int _deviceState;

  bool isDisconnecting = false;

  Map<String, Color> colors = {
    'onBorderColor': Colors.green,
    'offBorderColor': Colors.red,
    'neutralBorderColor': Colors.transparent,
    'onTextColor': Colors.green[700],
    'offTextColor': Colors.red[700],
    'neutralTextColor': Colors.blue,
  };

  // To track whether the device is still connected to Bluetooth
  bool get isConnected => connection != null && connection.isConnected;

  // Define some variables, which will be required later
  List<BluetoothDevice> _devicesList = [];
  bool _connected = false;
  bool _isButtonUnavailable = false;
  var dat;

  @override
  void initState() {
    super.initState();

    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    _deviceState = 0; // neutral

    // If the bluetooth of the device is not enabled,
    // then request permission to turn on bluetooth
    // as the app starts up
    enableBluetooth();

    // Listen for further state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;
        if (_bluetoothState == BluetoothState.STATE_OFF) {
          _isButtonUnavailable = true;
        }
        getPairedDevices();
      });
    });
  }

  @override
  void dispose() {
    // Avoid memory leak and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection.dispose();
      connection = null;
    }

    super.dispose();
  }

  // Request Bluetooth permission from the user
  Future<void> enableBluetooth() async {
    // Retrieving the current Bluetooth state
    _bluetoothState = await FlutterBluetoothSerial.instance.state;

    // If the bluetooth is off, then turn it on first
    // and then retrieve the devices that are paired.
    if (_bluetoothState == BluetoothState.STATE_OFF) {
      await FlutterBluetoothSerial.instance.requestEnable();
      await getPairedDevices();
      return true;
    } else {
      await getPairedDevices();
    }
    return false;
  }

  // For retrieving and storing the paired devices
  // in a list.
  Future<void> getPairedDevices() async {
    List<BluetoothDevice> devices = [];

    // To get the list of paired devices
    try {
      devices = await _bluetooth.getBondedDevices();
    } on PlatformException {
      print("Error");
    }

    // It is an error to call [setState] unless [mounted] is true.
    if (!mounted) {
      return;
    }

    // Store the [devices] list in the [_devicesList] for accessing
    // the list outside this class
    setState(() {
      _devicesList = devices;
    });
  }


  List<Container> _getDeviceItems() {
    var ScrW = MediaQuery
        .of(context)
        .size
        .width;
    var ScrH = MediaQuery
        .of(context)
        .size
        .height;
    List<Container> containers = [];
    if (_devicesList.isEmpty) {
      containers.add(
        Container( child: Center(
            child: Text('No Connections Found',
              style: TextStyle(color: Colors.white, fontSize: ScrH*pageHpercent*23.0,),
            ))),
      );
    } else {
      _devicesList.forEach((device) {
        containers.add(
          Container(
            margin: EdgeInsets.only(
              top: ScrH*pageHpercent*10,
            ),
            height: ScrH * 0.061,

            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    children: <Widget>[
                      GestureDetector(
                        onTap: () async{
          BluetoothConnection connection = await BluetoothConnection.toAddress(device.address);
          show('Connected to the device');
          setState(() {
          _connected = true;
          });
          connection.input.listen((Uint8List data) {
          setState(() {
            Globals.dat = ('${ascii.decode(data)}');
          });});},
          child: Padding(
          padding:  EdgeInsets.only(
          left: 10,
          right: 10,
          bottom: ScrH*pageHpercent*8,
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment
              .spaceBetween,
          children: [ Flexible( child: Align(alignment: Alignment.centerLeft,
          child: Container(
          width:150,
          child:Text(device.name,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
          color: Colors.white, fontSize: ScrH*pageHpercent*20.0,))))),
                              Align(
                                  alignment: Alignment.centerRight,
                                  child: Row(children: [Text(_connected ? 'Connected' : 'Not Connected',
                                      style: TextStyle(
                                        color: Colors.blueGrey[100],
                                        fontSize: ScrH*pageHpercent*16.0,)),
                                    Padding(
                                      padding:  EdgeInsets.only(left: 10,),
                                      child: IconButton(
                                        padding: EdgeInsets.zero,
                                        constraints: BoxConstraints(),
                                        icon: new Icon(Icons.info_outline_rounded,
                                          size: 29.0,
                                        ),
                                        color: Colors.orange,
                                        onPressed: () async{
                                        setState(() {
                                        _deviceState = 0;
                                        });

                                        await connection.close();
                                        show('Device disconnected');
                                        _connected = false;},
                                      ),)
                                  ]))
                            ],
                          ),
                        ),

                      ),
                      Divider(
                        height: ScrH * 0.011,
                        color: Colors.orange,
                        indent: 15,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),

        );
      });
    }
    return containers;
  }



  @override
  Widget build(BuildContext context) {
    var ScrW = MediaQuery
        .of(context)
        .size
        .width;
    var ScrH = MediaQuery
        .of(context)
        .size
        .height;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.blueGrey[900],
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(ScrH * 0.098),
          child: Container(
            child: Center(
                child: Text('Bluetooth',
                    style: TextStyle(
                        fontSize: ScrH*pageHpercent*48.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white))),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),
              color: Colors.blueGrey[900],
              boxShadow: [
                BoxShadow(
                  color: Colors.orange[700].withOpacity(1),
                  spreadRadius: 4,
                  blurRadius: 10,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),

          )),

      body: Stack( children: [ListView(
        padding: EdgeInsets.only(top: ScrH*pageHpercent*20),
        children: _getDeviceItems()
    ),
        Align(alignment: Alignment.bottomCenter,
        child:Container(
        margin: EdgeInsets.only(bottom: ScrH*pageHpercent*30.0),
        child : ElevatedButton(
    style: ElevatedButton.styleFrom(
    textStyle: TextStyle(fontSize:  ScrH*pageHpercent*20, color: Colors.white, fontWeight: FontWeight.bold,),
    primary: Colors.orange,
    shadowColor: Colors.orange,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30), // <-- Radius
      ),
    ),
    onPressed: () {Navigator.of(context).push(MaterialPageRoute(builder: (context) => Page1()));},
    child: Padding( padding: EdgeInsets.all(ScrH*pageHpercent*10),
    child: const Text('Home')))
    ))
    ]
    ));
  }

  Future show(
      String message, {
        Duration duration: const Duration(seconds: 3),
      }) async {
    await new Future.delayed(new Duration(milliseconds: 100));
    _scaffoldKey.currentState.showSnackBar(
      new SnackBar(
        content: new Text(
          message,
        ),
        duration: duration,
      ),
    );
  }



}