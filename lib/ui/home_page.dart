import 'dart:convert';

import 'package:buscador_gifs/ui/gif_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _limitForTrending = 20;
  int _limitForQuering = 19;
  int _offset = 0;
  String _search = "";

  Future<Map> _getGifs() async {
    http.Response response;
    Uri uri;

    if (_search.isEmpty) {
      uri = Uri.parse("https://api.giphy.com/v1/gifs/trending?api_key=blhdtbZbUkUZttEjUeS5fp3F0vlvVQsx&limit=$_limitForTrending&rating=g");
    } else {
      uri = Uri.parse("https://api.giphy.com/v1/gifs/search?api_key=blhdtbZbUkUZttEjUeS5fp3F0vlvVQsx&q=$_search&limit=$_limitForQuering&offset=$_offset&rating=g&lang=en");
    }

    response = await http.get(uri);

    return json.decode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network(
            "https://developers.giphy.com/static/img/dev-logo-lg.7404c00322a8.gif"),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10.0),
            child: TextField(
              onSubmitted: (value) {
                setState(() {
                  _search = value;
                });
              },
              decoration: InputDecoration(
                labelText: "Pesquise Aqui!",
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(),
              ),
              style: TextStyle(color: Colors.white, fontSize: 18.0),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: _getGifs(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return Container(
                      height: 200.0,
                      width: 200.0,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 5.0,
                      ),
                    );
                  default:
                    if (snapshot.hasError) return Container(
                      color: Colors.red,
                      child: Text(snapshot.error.toString()),
                    );
                    return _createGifTable(context, snapshot);
                }
              },
            ),
          )
        ],
      ),
    );
  }

  int _getCount(List data) {
    return _search.isEmpty ? data.length : data.length + 1;
  }

  Widget _createGifTable(context, snapshot) {
    return GridView.builder(
      padding: EdgeInsets.all(10.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
      ),
      itemCount: _getCount(snapshot.data["data"]),
      itemBuilder: (context, index) {
        if (_search.isEmpty || index < snapshot.data["data"].length) {
          return GestureDetector(
            child: FadeInImage.memoryNetwork(
              placeholder: kTransparentImage,
              image: snapshot.data["data"][index]["images"]["fixed_height"]["url"],
              height: 300.0,
              fit: BoxFit.cover,
            ),
            onLongPress: () {
              Share.share(snapshot.data["data"][index]["images"]["fixed_height"]["url"]);
            },
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => GifPage(snapshot.data["data"][index])));
            },
          );
        }

        return Container(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _offset += _limitForQuering;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: Colors.white, size: 70.0),
                  Text("Carregar mais...", style: TextStyle(color: Colors.white, fontSize: 22.0)),
                ],
              ),
            )
          ),
        );
      },
    );
  }
}
