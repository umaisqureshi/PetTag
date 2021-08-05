import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:pett_tagg/utilities/firebase_credentials.dart';
import 'package:pett_tagg/widgets/localBouncingWidget.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';

class BoostDialog extends StatefulWidget {
  @override
  _BoostDialogState createState() => _BoostDialogState();
}

class _BoostDialogState extends State<BoostDialog>
    with TickerProviderStateMixin {
  AnimationController _controller;
  Tween<double> _tween = Tween(begin: 0.75, end: 2);
  double h1 = 110;
  double w1 = 110;
  double h2 = 110;
  double w2 = 110;
  double h3 = 110;
  double w3 = 110;

  String petId;

  bool visibility1 =false;
  bool visibility2 =false;
  bool visibility3 =false;

  StreamSubscription _purchaseUpdatedSubscription;
  StreamSubscription _purchaseErrorSubscription;
  List<String> productIds = ['1_first_boost', '2_second_boost', '3_third_boost'];
  List<IAPItem> _items = [];
  List<PurchasedItem> _purchases = [];
  IAPItem purchaseIt;

  initState() {
    getPetId();
    super.initState();
    initPlatformState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 700));
  }

  getPetId()async{
    await FirebaseFirestore.instance.collection("User").doc(FirebaseCredentials().auth.currentUser.uid).get().then((value){
      petId = value.data()['pet'][0];
    });
  }

  Future<void> initPlatformState() async {
    // prepare
    var result = await FlutterInappPurchase.instance.initConnection;
    print('result: $result');

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    // refresh items for android
    // String msg = await FlutterInappPurchase.instance.consumeAllItems;
    // print('consumeAllItems: $msg');
    try {
      String msg = await FlutterInappPurchase.instance.consumeAllItems;
      print('consumeAllItems: $msg');
    } catch (err) {
      print('consumeAllItems error: $err');
    }

    _purchaseUpdatedSubscription = FlutterInappPurchase.purchaseUpdated.listen((productItem) {
      print('purchase-updated: $productItem');
      FirebaseFirestore.instance.collection("Pet").doc(petId).update({
        'boosted' : true,
        'boostedTimestamp' : DateTime.now().millisecondsSinceEpoch,
      });
    });

    _purchaseErrorSubscription = FlutterInappPurchase.purchaseError.listen((purchaseError) {
      print('purchase-error: $purchaseError');
    });
    await _getProduct();
  }

  Future<Null> _getProduct() async {
    List<IAPItem> items = await FlutterInappPurchase.instance.getProducts(productIds);
    for (var item in items) {
      print('${item.toString()}');
      this._items.add(item);
    }
    setState(() {
      this._items = items;
    });
  }

  Future<Null> _buyProduct(IAPItem item) async {
    try {
      PurchasedItem purchased = await FlutterInappPurchase.instance.requestPurchase(item.productId);
      PurchaseState state = purchased.purchaseStateAndroid;
      print("\n\n\nState of purchase : $state");
      String msg = await FlutterInappPurchase.instance.consumeAllItems;
      print('consumeAllItems: $msg');
    } catch (error) {
      print('$error');
    }
  }

  Future _getPurchaseHistory() async {
    List<PurchasedItem> items = await FlutterInappPurchase.instance.getPurchaseHistory();
    for (var item in items) {
      print('Purchased Items  : ${item.toString()}');
      this._purchases.add(item);
    }

    setState(() {
      this._items = [];
      this._purchases = items;
    });
  }

  _onPressed(BuildContext context) {
    print("CLICK");
  }

  @override
  Future<void> dispose() async {
    // TODO: implement dispose
    super.dispose();
    await FlutterInappPurchase.instance.endConnection;
    _purchaseUpdatedSubscription.cancel();
    _purchaseErrorSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 2,
      backgroundColor: Color(0xFFFFF6F7),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        height: 530,
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(bottom: 10),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20)),
                        color: Colors.pink,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                            backgroundImage: AssetImage('assets/logo.png'),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Text(
                            "Out of Boots!",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 17,
                              height: 1.4,
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            "Be a top profile in your area for 30 minutes to get more matches.",
                            style: TextStyle(color: Colors.white, height: 1.4),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            height: 110,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                //Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children:[
                    // this._renderProducts(),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            h3 = 110;
                            h2 = 110;
                            h1 = 120;
                            visibility1=true;
                            visibility2=false;
                            visibility3=false;
                            purchaseIt = _items[0];
                          });
                        },
                        child: AnimatedContainer(
                          duration: Duration(seconds: 1),
                          curve: Curves.elasticOut,
                          height: h1,
                          decoration: BoxDecoration(
                            border: visibility1 ? Border.all(color: Colors.pinkAccent, width: 2): null,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    "1",
                                    style: TextStyle(
                                        fontSize: 25,
                                        color: Colors.black54,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text("Boost",
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.black54,
                                          fontWeight: FontWeight.bold)),
                                  Text("${_items.isEmpty ? "0": _items[0].price}  ${_items.isEmpty ? "USD": _items[0].currency}",
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.black54,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            h3 = 110;
                            h2 = 120;
                            h1 = 110;
                            visibility1=false;
                            visibility2=true;
                            visibility3=false;
                            purchaseIt = _items[1];
                          });
                        },
                        child: AnimatedContainer(
                          duration: Duration(seconds: 1),
                          curve: Curves.elasticOut,
                          decoration: BoxDecoration(
                            border: visibility2 ? Border.all(color: Colors.pinkAccent, width: 2): null,
                          ),
                          child: Container(
                            height: h2,
                            decoration: BoxDecoration(
                              color: Colors.white,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    "2",
                                    style: TextStyle(
                                        fontSize: 25,
                                        color: Colors.black54,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text("Boost",
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.black54,
                                          fontWeight: FontWeight.bold)),
                                  Text("${_items.isEmpty ? "0": _items[1].price}  ${_items.isEmpty ? "USD": _items[1].currency}",
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.black54,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            h3 = 120;
                            h2 = 110;
                            h1 = 110;
                            visibility1=false;
                            visibility2=false;
                            visibility3=true;
                            purchaseIt = _items[2];
                          });
                        },
                        child: AnimatedContainer(
                          duration: Duration(seconds: 1),
                          curve: Curves.elasticOut,
                          decoration: BoxDecoration(
                          border: visibility3 ? Border.all(color: Colors.pinkAccent, width: 2): null,
                        ),
                          child: Container(
                            height: h3,
                            decoration: BoxDecoration(
                              color: Colors.white,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    "3",
                                    style: TextStyle(
                                        fontSize: 25,
                                        color: Colors.black54,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text("Boost",
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.black54,
                                          fontWeight: FontWeight.bold)),
                                  Text("${_items.isEmpty ? "0": _items[2].price}  ${_items.isEmpty ? "USD": _items[2].currency}",
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.black54,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ]
                ),
              ],
            ),
            Container(
              height: MediaQuery.of(context).size.height / 4.3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width / 2,
                    height: 50,
                    child: RaisedButton(
                      color: Colors.pink,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      child: Text(
                        "BOOST ME",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      onPressed: ()async{
                        await _buyProduct(purchaseIt);


                      },
                    ),
                  ),
                  Container(
                    height: 20,
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          height: 2,
                          width: MediaQuery.of(context).size.width / 3.5,
                          color: Colors.black12,
                        ),
                        Text(
                          "or",
                          style: TextStyle(color: Colors.black12),
                        ),
                        Container(
                          height: 2,
                          width: MediaQuery.of(context).size.width / 3.5,
                          color: Colors.black12,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width / 1.8,
                    height: 50,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Get PetTag+ Plus",
                          style: TextStyle(
                            color: Colors.pink,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                        Text(
                          "(1 free Boost every month)",
                          style: TextStyle(
                            color: Colors.pink,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );

  }

}
