// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;

import '../model/order.dart';


class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = true;
  List orders = [];
  List acceptedOrders = [];
  List file = [];

  @override
  void initState() {
    startTimer();
    
    // TODO: implement initState
    super.initState();
  }

  // Future myFuture() async {
  //   return Future.delayed(Duration(seconds: 5), () {
  //     setState(() {
  //       isLoading = false;
  //       orders = ['data0', 'data1', 'data2'];
  //     });
  //   });
  // }
  void startTimer(){
    var timer = Timer.periodic(Duration(seconds: 1), (timer) { 
      getOrders();
    }
    );
  }
  getOrders() async {
    file = [];
    // 'https://restorant-backend-i0ix.onrender.com/';
    // http://10.0.2.2:3003
    final uri =
        Uri.parse('https://shopping-backend-njou.onrender.com/getorders');
    var response = await http.get(uri);
    var responseData = json.decode(response.body);
    for (var ord in responseData) {
      Order order = Order(
          id: ord['_id'] ?? '',
          phone: ord['phone'] ?? '',
          address: ord['address'] ?? '',
          items: ord['items'].toString() ?? '',
          price: ord['price']?? '',);
      file.add(order);
    }
     
    if(orders.length == file.length){

      } else{
         setState(() {
           orders = file;
         });
      }
    print(orders);
    print(responseData);
  }

  // deleteOrder() async {
  //   final uri =
  //       Uri.parse('http://restorant-backend-i0ix.onrender.com/deleteorder');
  //   var response = await http.post(uri);

  //   setState(() {});
  // }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          isLoading = true;
        });
        getOrders();
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Ordered items',
            style:
                GoogleFonts.cinzel(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          leading: Builder(
            builder: (context) {
              return IconButton(
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                icon: Icon(
                  Icons.menu_outlined,
                ),
              );
            },
          ),
           
        ),
        body: isLoading
            ? Container(
                margin: const EdgeInsets.all(8.0),
                child: ListView.builder(
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      return Shimmer.fromColors(
                        baseColor: Colors.grey.shade200,
                        highlightColor: Colors.white,
                        child: Container(
                          height: size.height * 0.3,
                          width: double.infinity,
                          margin: EdgeInsets.only(bottom: 20),
                          color: Colors.red,
                          child: Text('data'),
                        ),
                      );
                    }),
              )
            : Container(
                margin: EdgeInsets.all(16),
                padding: EdgeInsets.all(16),
                color: Colors.green[200],
                child: ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    return Container(
                      height: size.height * 0.3,
                      margin: EdgeInsets.only(bottom: 20),
                      padding: EdgeInsets.only(bottom: 35),
                      child: Card(
                        color: Colors.white,
                        child: ListTile(
                          title: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text('phone: ' + orders[index].phone),
                                Text('address : ' + orders[index].address),
                                Text('items: ' + orders[index].items),
                                Text('price.: ' + orders[index].price),
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green[300],
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            acceptedOrders.add(orders[index]);
                                            orders.remove(orders[index]);
                                          });
                                        },
                                        child: Text(
                                          'Accept',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red[300],
                                        ),
                                        onPressed: () async {
                                          final uri = Uri.parse(
                                              'https://shopping-backend-njou.onrender.com/deleteorder');
                                          var response = await http.post(uri,
                                              body: {
                                                "id": orders[index].id,
                                              });
                                  
                                          setState(() {
                                            orders.remove(orders[index]);
                                          });
                                        },
                                        child: Text(
                                          'Cancel',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      )
                                    ],
                                  ),
                                ),SizedBox(height: 16,)
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
         
      ),
    );
  }
}
