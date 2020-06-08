import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:ootw/detail.dart';
import 'package:ootw/weather.dart';
import 'package:weather/weather_library.dart';

class ootwPage extends StatefulWidget {

  final Weather weather;
  final FirebaseUser user;

  ootwPage(this.weather, this.user);

  @override
  _ootwPageState createState() => _ootwPageState();
}

class _ootwPageState extends State<ootwPage> {


  String selected;

  @override
  Widget build(BuildContext context) {



    return Scaffold(
      appBar: buildAppBar(),
      body: buildBody(context),
    );
  }

  Widget buildBody(BuildContext context){

    List<String> ootwList;
    setState(() {
       ootwList = loadOotw();
    });
    print(ootwList);



    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(padding: EdgeInsets.all(10),),
            Stack(
              children: <Widget>[

                Container(
                  height: 200,
                  width: double.infinity,

                  color: Color(0xFFEFEDED),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('# OOTW', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black54),),
                      SizedBox(height: 10,),
                      Expanded(
                        child: ListView.builder(
                               itemCount: ootwList.length,
                               itemBuilder: (BuildContext context, int index) {
                                 return Align(
                                   alignment: Alignment.centerLeft,
                                   child: FlatButton(

                                     splashColor: Colors.blueAccent,
                                     child: Text('#'+ootwList[index],style: TextStyle(fontSize: 15, color: selected == ootwList[index]? Colors.black : Colors.grey),),
                                     onPressed: () {
                                       setState(() {
                                         selected = ootwList[index];
                                         print(selected);
                                       });
                                     },),
                                 );
                               }),
                      )
                    ],
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Image.asset('images/tshirt.png'),
                ),
                Positioned(
                  bottom: 40,
                  right: 25,
                  child: Image.asset('images/short.png'),
                ),
                Positioned(
                  bottom: 40,
                  right: 100,
                  child: Image.asset('images/shoes.png'),
                ),
              ],
            ),
            SizedBox(height: 40,),

            Text(selected == null ? '카테고리를 선택해 주세요.' : '\'$selected\' 에 대한 검색 결과입니다.'),
            selected == null?
            Container():
            Container(
                height: 450,

                child: _buildCard(context)),
          ],
        ),
      )
    );
  }
//@todo 성별 추가되면 콜렉션 불러오는거 고치기
  Widget _buildCard(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('여성의류').where('category', isEqualTo: selected).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        //return _buildList(context, snapshot.data.documents);
        return GridView.count(
          crossAxisCount: 3,
          //padding: EdgeInsets.all(16.0),
          //childAspectRatio: 8.0 / 9.0,
          children: _buildList(context,snapshot.data.documents),
        );
      },
    );
  }

  List<Card> _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return snapshot.map((data) => _buildListItem(context, data)).toList();

  }

  Card _buildListItem(BuildContext context, DocumentSnapshot data) {
    final record = Record.fromSnapshot(data);

    return Card(
      clipBehavior: Clip.antiAlias,

      child: InkWell(
          onTap:() => Navigator.push(context, MaterialPageRoute(builder: (context) => detailPage(record,widget.weather,widget.user))),
          child: Container(
              child: Hero(
                  tag : record.name,
                  child: Image.network(record.img))
          )
      )
    );
  }

  Widget buildAppBar(){
    return AppBar(

      titleSpacing: 0.0,

      backgroundColor: Color(0xFFD2F0F7),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: Text(widget.weather.areaName, style: TextStyle(color: Color(0xFF5F5B5B)),),
          ),
          SizedBox(width: 50,),
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,

              children: <Widget>[

                Text(widget.weather.temperature.celsius.toStringAsFixed(0), style: TextStyle(color: Colors.black,fontSize:40,fontWeight:FontWeight.bold),),
                SizedBox(width: 5,),
                Column(
                  children: <Widget>[
                    Text('o', style: TextStyle(color: Colors.black,fontSize:20,fontWeight:FontWeight.bold),),
                    SizedBox(height: 30),
                  ],
                ),
                SizedBox(
                    width: 60,
                    child:icon(widget.weather.weatherMain))
              ],
            ),
          ),
        ],
      ),
      actions: <Widget>[

      ],
    );

  }

  Widget icon(String descrip){
    if(descrip=='Clouds'){
      return Image.asset('images/clouds.png');
    }
    else if(descrip=='Clear'){
      return Image.asset('images/clear.png');
    }
    else if(descrip=='Rain'){
      return Image.asset('images/rain.png');
    }
    else{
      return Image.asset('images/otherwise.png');
    }
  }
//@todo 성별에 따라 다르게 리턴하기 + 보완
  loadOotw() {

    if(widget.weather.temperature.celsius >=25 )
      return ['티셔츠','바지','청바지'];
    else if(widget.weather.temperature.celsius <25 && widget.weather.temperature.celsius >15)
      return ['카디건','블라우스/셔츠','점퍼', '바지','청바지' ];
  }
}



class Record {
  final String name;
  final String url;
  final String img;
  final String documentId;
  final String price;

  final DocumentReference reference;

  Record.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['name'] != null),
        assert(map['link'] != null),
        assert(map['img'] != null),
        assert(map['docID'] != null),


        name = map['name'],
        url = map['link'],
        img = map['img'],
        documentId = map['docID'],
        price = map['price'];




  Record.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

}




