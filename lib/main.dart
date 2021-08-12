import 'dart:convert';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share/share.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _random = new Random();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  List data2 = [];

  DateFormat dateformat = DateFormat("yyyy-MM-dd hh:mm:ss");
  var buffer = [];
  var listToShow = [];
  var listToShow2 = [];
  var displayformat;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await showinit();
      displayformat = await getBoolValuesSF();
    });

    super.initState();
  }

  share(BuildContext context, int index) {
    Share.share("${listToShow[index]['user']} - ${listToShow[index]['phone']}",
        subject: 'Contacts');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () => setState(() {
              swapBoolSF();
            }),
            icon: Icon(Icons.change_circle),
          ),
        ],
      ),
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        onRefresh: updateDataInList,
        onLoading: showAllData,
        controller: _refreshController,
        footer: CustomFooter(
          builder: (BuildContext context, LoadStatus mode) {
            Widget body;
            if (mode == LoadStatus.idle && listToShow2.length != data2.length) {
              body = Text('Pull Up to Load More');
            } else if (mode == LoadStatus.loading) {
              body = CupertinoActivityIndicator();
            } else if (mode == LoadStatus.failed) {
              body = Text("Load Failed!Click retry!");
            } else if (mode == LoadStatus.loading) {
              body = Text("release to load more");
            } else if (listToShow2.length == data2.length) {
              body = Text("You have reach the end of list");
            }
            return Container(
              height: 55.0,
              child: Center(child: body),
            );
          },
        ),
        child: ListView.builder(
          itemCount: listToShow2.length,
          itemBuilder: (context, index) {
            return ListTile(
              onTap: () {
                share(context, index);
              },
              //trailing: Text(data2[i]['check-in']),
              leading: Text((index + 1).toString()),
              trailing: displayformat
                  ? contacttimeago(listToShow[index]['check-in'])
                  : contactexacttime(listToShow[index]['check-in']),
              title: Text(listToShow[index]['user']),
              subtitle: Text(listToShow[index]['phone']),
            );
          },
        ),
      ),
    );
  }

//
  showinit() async {
    final String response =
        await DefaultAssetBundle.of(context).loadString("assets/contacts.json");
    data2 = await json.decode(response.toString());
    buffer = [];
    int i = 0;
    // List<DateTime> newProducts = [];
    // DateFormat format = DateFormat("yyyy-MM-dd hh:mm:ss");
    do {
      listToShow2.add((data2[listToShow2.length]['check-in']));
      // print(listToShow2);
      //listToShow.add(data2[listToShow.length]);
    } while (listToShow2.length < 15);

    listToShow2.sort((b, a) => a.compareTo(b));
    for (var index in listToShow2) {
      for (var index2 in data2) {
        if (index2['check-in'].contains(index)) {
          // print(index2['check-in'].indexOf(index));
          // print(index2['check-in']);
          buffer.add(i);
        }
        i++;
      }
      i = 0;
    }

    for (var ascend in buffer) {
      listToShow.add((data2[ascend]));
      //listToShow.add(data2[listToShow.length]);
    }
    setState(() {
      data2;
      listToShow;
    });
  }

//refresh to generate 5 random set
  updateDataInList() async {
    var randomnumber;
    List randomnumberlist = [];
    buffer = [];
    listToShow = [];
    listToShow2 = [];
    int i = 0;
    await Future.delayed(Duration(milliseconds: 1000));
    setState(() {
      //to generate 5 unique number
      while (randomnumberlist.length < 5) {
        randomnumber = _random.nextInt(data2.length);
        if (randomnumberlist.contains(randomnumber)) {
          //do ntg and continue loop
        } else {
          randomnumberlist.add(randomnumber);
          listToShow2.add(data2[randomnumber]['check-in']);
        }
      }

      listToShow2.sort((b, a) => a.compareTo(b));
      for (var index in listToShow2) {
        for (var index2 in data2) {
          if (index2['check-in'].contains(index)) {
            // print(index2['check-in'].indexOf(index));
            // print(index2['check-in']);
            buffer.add(i);
          }
          i++;
        }
        i = 0;
      }
      print(buffer);
      for (var ascend in buffer) {
        listToShow.add((data2[ascend]));
        //listToShow.add(data2[listToShow.length]);
      }
      print(listToShow);
    });

    _refreshController.refreshCompleted();
  }

//pull down to load all data set
  showAllData() async {
    await Future.delayed(Duration(milliseconds: 1000));

    _refreshController.loadComplete();
    listToShow = [];
    listToShow2 = [];
    buffer = [];
    int i = 0;
    // List<DateTime> newProducts = [];
    // DateFormat format = DateFormat("yyyy-MM-dd hh:mm:ss");
    while (listToShow2.length != data2.length) {
      listToShow2.add((data2[listToShow2.length]['check-in']));
      //print(listToShow2[listToShow2.length]);
      // print(data2[listToShow2.length]['check-in']);
    }

    listToShow2.sort((b, a) => a.compareTo(b));
    for (var index in listToShow2) {
      for (var index2 in data2) {
        if (index2['check-in'].contains(index)) {
          // print(index2['check-in'].indexOf(index));
          // print(index2['check-in']);
          buffer.add(i);
        }
        i++;
      }
      i = 0;
    }
    for (var ascend in buffer) {
      listToShow.add((data2[ascend]));
      //listToShow.add(data2[listToShow.length]);
    }
    setState(() {
      listToShow;
    });
    _refreshController.loadComplete();
  }

//get sharedpreferences display check in format
  getBoolValuesSF() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return bool
    displayformat = prefs.getBool('boolValue') ?? false;
    print(displayformat);
    return displayformat;
  }

  //swap boolvalue to display different format
  swapBoolSF() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (displayformat == true) {
      prefs.setBool("boolValue", false);
      displayformat = false;
    } else {
      prefs.setBool("boolValue", true);
      displayformat = true;
    }
    displayformat = prefs.getBool('boolValue');
    return displayformat;
  }

  //display check-in data based in json
  contactexacttime(datetime) {
    final contactdatetime = dateformat.parse(datetime);
    String test = contactdatetime.toString();
    String time = test.split(".")[0];
    return Text(time);
  }

//display check-in with timeago format
  contacttimeago(datetime) {
    final contactdatetime = dateformat.parse(datetime);

    return Text(timeago.format(contactdatetime));
    //return Text(timeAgo + ' ago');
  }
}
/*
  Widget build(BuildContext context) {RR
    return Scaffold(
      body: FutureBuilder(
        future: DefaultAssetBundle.of(context).loadString("/contacts.json"),
        builder: (context, snapshot) {
          final contacts = json.decode(snapshot.data.toString());RS
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(child: CircularProgressIndicator());
            default:
              if (snapshot.hasError) {
                return Center(child: Text('Some error occurred!'));
              } else {
                return ListView.builder(
                  itemCount: contacts.length,
                  itemBuilder: (ctx, i) {
                    
                    return ListTile(
                      trailing: Text(contacts[i]['check-in']),
                      title: Text(contacts[i]['user']),
                      subtitle: Text(contacts[i]['phone']),
                    );
                  },
                );
              }
          }
        },
      ),
    );
  }
SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        onRefresh: updateDataInList,
        onLoading: showAllData,
        controller: _refreshController,
        footer: CustomFooter(
          builder: (BuildContext context, LoadStatus mode) {
            Widget body;
            if (mode == LoadStatus.loading) {
              body = CupertinoActivityIndicator();
            } else if (mode == LoadStatus.failed) {
              body = Text("Load Failed!Click retry!");
            } else if (mode == LoadStatus.canLoading) {
              body = Text("release to load more");
            } else if (listToShow.length == data.length) {
              body = Text("You have reached the end of the list");
            }
            return Container(
              height: 55.0,
              child: Center(child: body),
            );
          },
        ),
        child: ListView.builder(
          itemCount: listToShow.length,
          itemBuilder: (context, i) {
            return Ink(
              color: Colors.blueGrey,
              child: ListTile(
                title: Text(listToShow[i].toString()),
              ),
            );
          },
        ),
      ), */
