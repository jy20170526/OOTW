// Copyright 2018-present the Flutter authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/material.dart';
//import 'package:intl/intl.dart';
//import 'model/products_repository.dart';
//import 'model/product.dart';
import 'profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'add.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
//import 'package:Shrine/detail.dart';
import 'dart:io';
//import 'package:uuid/uuid.dart';
//import 'package:firebase_storage/firebase_storage.dart';
import 'dart:async';
import 'package:weather/weather_library.dart';

//우리집: 37.523218, 126.871777
enum AppState { NOT_DOWNLOADED, DOWNLOADING, FINISHED_DOWNLOADING }

class HomePage extends StatefulWidget {
  final FirebaseUser user;
  int type;
  HomePage(this.user, this.type);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String key = '35557bb866e1fe9ca193680d9dd373de';
  WeatherStation ws;
  List<Weather> _data = [];
  AppState _state = AppState.NOT_DOWNLOADED;
  double lat, lon;

  @override

  void initState() {
    super.initState();
    ws = new WeatherStation(key);
  }

  void queryForecast() async {
    /// Removes keyboard
    FocusScope.of(context).requestFocus(FocusNode());
    setState(() {
      _state = AppState.DOWNLOADING;
    });

    List<Weather> forecasts = await ws.fiveDayForecast(lat, lon);
    setState(() {
      _data = forecasts;
      _state = AppState.FINISHED_DOWNLOADING;
    });
  }

  void queryWeather() async {
    /// Removes keyboard
    FocusScope.of(context).requestFocus(FocusNode());

    setState(() {
      _state = AppState.DOWNLOADING;
    });

    Weather weather = await ws.currentWeather(lat, lon);
    setState(() {
      _data = [weather];
      _state = AppState.FINISHED_DOWNLOADING;
    });
  }

  Widget contentFinishedDownload() {
    return Center(
      child: ListView.separated(
        itemCount: _data.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_data[index].toString()),
          );
        },
        separatorBuilder: (context, index) {
          return Divider();
        },
      ),
    );
  }

  Widget contentDownloading() {
    return Container(
        margin: EdgeInsets.all(25),
        child: Column(children: [
          Text(
            'Fetching Weather...',
            style: TextStyle(fontSize: 20),
          ),
          Container(
              margin: EdgeInsets.only(top: 50),
              child: Center(child: CircularProgressIndicator(strokeWidth: 10)))
        ]));
  }

  Widget contentNotDownloaded() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Press the button to download the Weather forecast',
          ),
        ],
      ),
    );
  }

  Widget _resultView() => _state == AppState.FINISHED_DOWNLOADING
      ? contentFinishedDownload()
      : _state == AppState.DOWNLOADING
      ? contentDownloading()
      : contentNotDownloaded();

  void _saveLat(String input) {
    lat = double.tryParse(input);
    print(lat);
  }

  void _saveLon(String input) {
    lon = double.tryParse(input);
    print(lon);
  }

  Widget _latTextField() {
    return Container(
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(color: Theme.of(context).dividerColor))),
        padding: EdgeInsets.all(10),
        child: TextField(
            decoration: InputDecoration(
                border: OutlineInputBorder(), hintText: 'Enter longitude'),
            keyboardType: TextInputType.number,
            onChanged: _saveLat,
            onSubmitted: _saveLat));
  }

  Widget _lonTextField() {
    return Container(
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(color: Theme.of(context).dividerColor))),
        padding: EdgeInsets.all(10),
        child: TextField(
            decoration: InputDecoration(
                border: OutlineInputBorder(), hintText: 'Enter longitude'),
            keyboardType: TextInputType.number,
            onChanged: _saveLon,
            onSubmitted: _saveLon));
  }

  Widget _weatherButton() {
    return FlatButton(
      child: Text('Fetch weather'),
      onPressed: queryWeather,
      color: Colors.blue,
    );
  }

  Widget _forecastButton() {
    return FlatButton(
      child: Text('Fetch forecast'),
      onPressed: queryForecast,
      color: Colors.blue,
    );
  }











  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.person,
            semanticLabel: 'profile',
          ),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage(widget.user, widget.type)));
          },
        ),
        title: Text('Main'),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.add,
              semanticLabel: 'add',
            ),
            onPressed: (){
              //Navigator.push(context, MaterialPageRoute(builder: (context) => AddPage(widget.user, widget.type)));
            },
          ),
        ],
      ),
      resizeToAvoidBottomInset: false,
    );
  }
  Widget _buildBody(){
    return Column(
      children: <Widget>[
        _latTextField(),
        _lonTextField(),
        _weatherButton(),
        _forecastButton(),
        Text(
          'Output:',
          style: TextStyle(fontSize: 20),
        ),
        Divider(
          height: 20.0,
          thickness: 2.0,
        ),
        Expanded(child: _resultView())
      ],
    );


    /*return StreamBuilder(
      stream: Firestore.instance.collection('post').snapshots(),
      builder: (BuildContext context, AsyncSnapshot snapshot){
        if(!snapshot.hasData){
          return Center(child: CircularProgressIndicator());
        }

        var items = snapshot.data.documents ?? [];

        return Center(
          child: SizedBox(
            width: 380,
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.72,
                  mainAxisSpacing: 5,
                  crossAxisSpacing: 3
              ),
              itemCount: items.length,
              itemBuilder: (context, index){
                return _buildListItem(context, items[index]);
              },
            ),
          ),
        );
      },
    );*/
  }
/*Widget _buildListItem(context, document){
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AspectRatio(
            aspectRatio: 12 / 11,
            child: Image.network(document['photoUrl'], fit: BoxFit.cover),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(13.0, 12.0, 0.0, 0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    document['name'],
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    '\$ '+document['price'].toString(),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey),
                  ),
                  Flexible(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        SizedBox(
                          width: 65,
                          child: FlatButton(
                            child: Text(
                              'more',
                              style: TextStyle(fontSize: 13, color: Colors.green[200]),
                            ),
                            onPressed: (){
                              //Navigator.push(context, MaterialPageRoute(builder: (context) => DetailPostPage(user, type, document)));
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }*/
}