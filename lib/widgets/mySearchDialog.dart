import 'package:flutter/material.dart';
import 'package:pett_tagg/constant.dart';
import 'package:pett_tagg/widgets/generic_shadow_button.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pett_tagg/repo/paymentRepo.dart' as repo;
import 'package:pett_tagg/models/packageDetail.dart';
import 'package:pett_tagg/models/packageData.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class MySearchDialog extends StatefulWidget {
  static const String mySearchDialogScreenDialog = "MySearchDialog";

  PackageDetail package;

  @override
  _MySearchDialogState createState() => _MySearchDialogState();
}

class _MySearchDialogState extends State<MySearchDialog> {
  bool petTagStandard = false;
  bool petTag = false;
  bool petTagBreeder = false;
  bool petTagRescuer = false;
  int _currentPos = 0;
  bool somethingSelected = false;
  PackageDetail packageDetail;
  int indexExtra = -1;
  Offerings _offerings;
  PurchaserInfo _purchaserInfo;

  PackageData pkgData;
  List<PackageData> pkgList = [
    PackageData(
        duration: "12",
        profileCount: 1,
        plan: "PetTag Standard",
        price: "0",
        index: 0),

    PackageData(
        duration: "12",
        profileCount: 2,
        plan: "PetTag+",
        price: "5",
        index: 1),

    PackageData(
        duration: "1",
        profileCount: 6,
        plan: "PetTag Breeder",
        price: "30",
        index: 2),

    PackageData(
        duration: "6",
        profileCount: 15,
        plan: "PetTag Rescuer",
        price: "25",
        index: 3),
  ];

  List<String> listPaths = [
    "assets/dogsAndCats/dog4.png",
    "assets/dogsAndCats/dog3.png",
    "assets/dogsAndCats/dog2.png",
    "assets/dogsAndCats/dog5.png",
  ];

  List<String> planList = [
    "PetTag Standard",
    "PetTag+",
    "PetTag Breeder",
    "PetTag Rescuer",
  ];

  List<String> duration = [
    "25 likes every 8 hours\nAd pop up every 10 swipes\n1 Pet Treat(superlike) per day\n1 pet profile\nPack Track\nPark finder\n5 photo and 2 video (pets) 3 owner",
    "Unlimited Likes\nSee who likes you\n1 booster shot\nNo ads\n5 Pet Treats(super likes)\nBack Track(rewind)\n2 pet profiles\nAdditional 5 photos and 2 video clips",
    "Set up a breeder profile\n30 photos\n3 booster shots\n6 profiles",
    "Only can be created by Shelters\n15 pet profiles\n3 photos/ 1 video clips\n3 boosts",
  ];

  saveProfile(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("ProfileType", value);
  }

  Future<void> fetchData() async {
    PurchaserInfo purchaserInfo;
    try {
      purchaserInfo = await Purchases.getPurchaserInfo();
    } catch (e) {
      print(e);
    }

    Offerings offerings;
    try {
      offerings = await Purchases.getOfferings();
      print("Offerings : ${offerings.all.length}");
    }  catch (e) {
      print(e);
    }
    if (!mounted) return;
    setState(() {
      _purchaserInfo = purchaserInfo;
      _offerings = offerings;

    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData();
    repo.getPkgInfo().then((value) {
      if(value!=null){
        packageDetail = value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              color: Colors.pink.withAlpha(255),
              padding: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context, false);
                    },
                    child: Material(
                      borderRadius: BorderRadius.circular(20),
                      elevation: 4.0,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.black,
                          gradient: RadialGradient(
                            colors: [
                              Colors.black,
                              Colors.white,
                            ],
                            stops: [0.5, 0.1],
                          ),
                        ),
                        child: Icon(
                          Icons.cancel_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    child: Column(
                      children: [
                        CarouselSlider.builder(
                          itemCount: 4,
                          itemBuilder: (context, index) {
                            return Container(
                              child: Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                      border: Border.all(
                                          color: Colors.white, width: 2),
                                    ),
                                    child: CircleAvatar(
                                      backgroundImage:
                                      AssetImage(listPaths[index]),
                                      radius: 50,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 1,
                                  ),
                                  Text(
                                    "${planList[index]}",
                                    style: dialogTitle.copyWith(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    "For ${duration[index]} months",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          options: CarouselOptions(
                              autoPlay: true,
                              autoPlayCurve: Curves.elasticInOut,
                              autoPlayAnimationDuration: Duration(seconds: 1),
                              enlargeCenterPage: false,
                              viewportFraction: 1.5,
                              height: 270,
                              onPageChanged: (index, reason) {
                                setState(() {
                                  _currentPos = index;
                                });
                              }),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: listPaths.map((url) {
                            int index = listPaths.indexOf(url);
                            return Container(
                              width: 8.0,
                              height: 8.0,
                              margin: EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 2.0),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentPos == index
                                    ? Color.fromRGBO(255, 255, 255, 0.9)
                                    : Color.fromRGBO(255, 255, 255, 0.4),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 200,
                  child: ListView.builder(
                    padding: EdgeInsets.all(8.0),
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: pkgList.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            Card(
                              margin: EdgeInsets.only(top: 20),
                              elevation: 4.0,
                              shape: pkgList[index].index == indexExtra
                                  ? RoundedRectangleBorder(
                                side: BorderSide(
                                    color: Colors.redAccent, width: 2),
                                borderRadius: BorderRadius.circular(5.0),
                              )
                                  : RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: Container(
                                height: 150,
                                width: 130,
                                child: Center(
                                  child: ListTile(
                                    isThreeLine: true,
                                    onTap: () async{
                                      setState(() {
                                        indexExtra = pkgList[index].index;
                                        pkgData = pkgList[index];
                                        print("Index Extra : $indexExtra");
                                      });

                                    },
                                    title: Text(
                                      pkgList[index].duration,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Color(0xFF854D5E),
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Container(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            "months",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Color(0xFF854D5E),
                                              fontSize: 17,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          Text(
                                            //"\$${pkgList[index].price}/month",
                                            index==0 ? "\$${pkgList[index].price}/month" : index==1 ? _offerings.getOffering("pettagplus").monthly.product.priceString + "/month" : index==2 ?  _offerings.getOffering("breeder_package").monthly.product.priceString + "/month" : _offerings.getOffering("rescuer_package").monthly.product.priceString + "/month",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Visibility(
                              visible: pkgList[index].index == indexExtra,
                              child: Container(
                                height: 35,
                                width: 100,
                                decoration: BoxDecoration(
                                  color: Colors.redAccent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                  child: Text(
                                    pkgList[index].plan,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                GenericBShadowButton(
                  buttonText: "Continue",
                  onPressed: pkgData == null
                      ? null
                      : () async {
                    var pcount = pkgData.profileCount;
                    var rcount = pkgData.profileCount;
                    if(pkgData.plan == "PetTag+"){
                      _purchaserInfo = await Purchases.purchasePackage(_offerings.getOffering("pettagplus").monthly);
                      if(_purchaserInfo.entitlements.active.isNotEmpty){
                        SharedPreferences prefs= await SharedPreferences.getInstance();
                        prefs.setString('packageName', 'PETTAGPLUS');
                      }
                      else{
                        print('Purchase Not Made');
                      }
                      print('purchase completed');
                    }
                    else if(pkgData.plan == 'PetTag Standard'){
                      /*SharedPreferences prefs= await SharedPreferences.getInstance();
                      prefs.setString('packageName', 'STANDARD');*/
                      Navigator.pop(context, false);
                      return;
                    }
                    else if(pkgData.plan == "PetTag Breeder"){
                      _purchaserInfo = await Purchases.purchasePackage(_offerings.getOffering("breeder_package").monthly);
                      if(_purchaserInfo.entitlements.active.isNotEmpty){
                        SharedPreferences prefs= await SharedPreferences.getInstance();
                        prefs.setString('packageName', 'BREEDER');
                      }
                      else{
                        print('Purchase Not Made');
                      }
                      print('purchase completed');
                    }
                    else if(pkgData.plan == "PetTag Rescuer"){
                      _purchaserInfo = await Purchases.purchasePackage(_offerings.getOffering("rescuer_package").monthly);
                      if(_purchaserInfo.entitlements.active.isNotEmpty){
                        SharedPreferences prefs= await SharedPreferences.getInstance();
                        prefs.setString('packageName', 'RESCUER');
                      }
                      else{
                        print('Purchase Not Made');
                      }
                      print('purchase completed');
                    }
                    if(packageDetail!=null){
                      pcount = packageDetail.profileCount+pkgData.profileCount;
                      rcount = packageDetail.remaining+pkgData.profileCount;
                    }
                    Map<String, dynamic> myMap = {
                      "pkgName": pkgData.plan,
                      "price": pkgData.price,
                      "profileCount": pcount,
                      "time": ((DateTime.now().millisecondsSinceEpoch) +
                          1000 * 525600 * 60),
                      "remaining": rcount
                    };
                    PackageDetail pkgDetail = PackageDetail.fromJson(myMap);
                    repo.storePkgInfo(pkgDetail);
                    repo.pkg.value = pkgDetail;
                    repo.pkg.notifyListeners();
                    Navigator.of(context).pop(true);
                  },
                ),
                SizedBox(
                  height: 10,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Column buildCarousalCard({String imagePath, String title, String period}) {
    return Column(
      children: [
        CircleAvatar(
          backgroundImage: AssetImage(imagePath),
          radius: 50,
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          title,
          style: dialogTitle,
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          "For $period months",
          style: dialogTitle,
        ),
        SizedBox(
          height: 20,
        ),
        Text(
          "Get 5 Free Super Likes a day & more",
          style: TextStyle(
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}
