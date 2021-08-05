import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pett_tagg/constant.dart';
import 'package:pett_tagg/widgets/customCard.dart';
import 'package:pett_tagg/utilities/firebase_credentials.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditInfoScreen extends StatefulWidget {
  static const String editInfoScreenRoute = "EditInfoScreen";

  String id;
  String ownerId;

  EditInfoScreen({this.id, this.ownerId});

  @override
  _EditInfoScreenState createState() => _EditInfoScreenState();
}

class _EditInfoScreenState extends State<EditInfoScreen> {
  int age = 1;
  int ownerAge = 15;
  String gender;
  String petSize;
  String name;
  String breed;
  String behaviour;
  String description;
  bool isLoading = false;
  String firstName;
  String lastName;
  String ownerDescription;

  final FirebaseAuth auth = FirebaseAuth.instance;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController userFirstname = TextEditingController();
  final TextEditingController userLastname = TextEditingController();
  final TextEditingController userDescription = TextEditingController();
  final TextEditingController petName = TextEditingController();
  final TextEditingController petAge = TextEditingController();
  final TextEditingController petBreed = TextEditingController();
  final TextEditingController petBehaviour = TextEditingController();
  final TextEditingController petDescription = TextEditingController();

  getPreviousPetData()async{
    await FirebaseCredentials().db.collection("Pet").doc(widget.id).get().then((value) {
      setState(() {
        age = value.data()['age'];
        gender = value.data()['sex'];
        petSize = value.data()['size'];
        name = value.data()['name'];
        petName.text = name;
        breed = value.data()['breed'];
        petBreed.text = breed;
        behaviour = value.data()['behaviour'];
        petBehaviour.text = behaviour;
        description = value.data()['description'];
        petDescription.text = description;
      });
    });

  }

  getPreviousOwnerData()async{
    await FirebaseFirestore.instance.collection("User").doc(widget.ownerId).get().then((value) {
      ownerAge = value.data()['age']<15 ? 15 : value.data()['age'];
      userFirstname.text = value.data()['firstName'];
      userLastname.text = value.data()['lastName'];
      userDescription.text = value.data()["description"];
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPreviousPetData();
    getPreviousOwnerData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          splashColor: Colors.transparent,
          icon: Icon(
            Icons.arrow_back,
            color: Colors.redAccent,
            size: 22,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Edit Profile",
          style: TextStyle(
              fontSize: 20, color: Colors.black54, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(top: 16, bottom: 0, left: 16, right: 16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomCard(
                height: 90,
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.only(left:12.0, top:14),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Pet Name",
                        style: pinkHeadingStyle,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left:4.0, right:10),
                        child: TextFormField(
                          controller: petName,
                          validator: (value){
                            return value.isEmpty ? "Required Field" : null;
                          },
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                              hintText: name,
                              hintStyle: TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                              border: InputBorder.none),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              /*petAgeSliderWidget(
                age: age,
              ),*/
              CustomCard(
                height: 92,
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.only(top: 14.0, right: 15, left: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(
                            "Pet Age",
                            style: pinkHeadingStyle,
                          ),
                          Spacer(),
                          Text(
                            "${age.toDouble().toString()} yr.",
                            style: TextStyle(
                              color: Colors.black38,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: Colors.redAccent,
                          trackHeight: 1,
                          inactiveTrackColor: Colors.black26,
                          thumbColor: Colors.redAccent,
                          //overlayColor: Color(0x29EB1555),
                          thumbShape:
                              RoundSliderThumbShape(enabledThumbRadius: 10.0),
                          overlayShape:
                              RoundSliderOverlayShape(overlayRadius: 25.0),
                        ),
                        child: Slider(
                          value: age.toDouble(),
                          min: 1,
                          max: 29,
                          onChanged: (double newValue) {
                            setState(() {
                              age = newValue.round();
                            });
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
              CustomCard(
                width: MediaQuery.of(context).size.width,
                height: 90,
                child: Padding(
                  padding: const EdgeInsets.only(top: 14.0, left: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Pet Sex",
                        style: pinkHeadingStyle,
                      ),
                      DropdownButtonFormField(
                        isExpanded: false,
                        validator: (value){
                          return value==null ? "Required Field" : null;
                        },
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          hintText: gender,
                          contentPadding: EdgeInsets.all(8.0),
                          hintStyle: hintTextStyle.copyWith(
                            color: Colors.black87,
                          ),
                          border: InputBorder.none,
                        ),
                        value: gender,
                        items: ['Male', 'Female']
                            .map<DropdownMenuItem<String>>(
                                (String value) => DropdownMenuItem(
                                      child: Text(value),
                                      value: value,
                                    ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            gender = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              CustomCard(
                width: MediaQuery.of(context).size.width,
                height: 90,
                child: Padding(
                  padding: const EdgeInsets.only(top: 14.0, left: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Pet Size",
                        style: pinkHeadingStyle,
                      ),
                      DropdownButtonFormField(
                        isExpanded: false,
                        validator: (value){
                          return value==null ? "Required Field" : null;
                        },
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          hintText: petSize ?? "Select Size",
                          contentPadding: EdgeInsets.all(8.0),
                          hintStyle: hintTextStyle.copyWith(
                            color: Colors.black87,
                          ),
                          border: InputBorder.none,
                        ),
                        value: petSize,
                        items: [
                          'Small',
                          'Medium',
                          'Large',
                          'Extra-Large'
                        ]
                            .map<DropdownMenuItem<String>>(
                                (String value) => DropdownMenuItem(
                                      child: Text(value),
                                      value: value,
                                    ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            petSize = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              CustomCard(
                height: 90,
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.only(left: 12.0, top: 14),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Pet Breed",
                        style: pinkHeadingStyle,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0, right: 10),
                        child: TextFormField(
                          controller: petBreed,
                          validator: (value){
                            return value.isEmpty ? "Required Field" : null;
                          },
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                              hintText: breed,
                              hintStyle: TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                              border: InputBorder.none),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              CustomCard(
                height: 120,
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.only(left: 12.0, top: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Pet Behaviour",
                        style: pinkHeadingStyle,
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0, right: 10),
                        child: TextFormField(
                          controller: petBehaviour,
                          validator: (value){
                            return value.isEmpty ? "Required Field" : null;
                          },
                          textInputAction: TextInputAction.next,
                          maxLength: 100,
                          buildCounter: (context,
                                  {currentLength, isFocused, maxLength}) =>
                              null,
                          decoration: InputDecoration(
                              hintText: behaviour ?? "Pet-Behaviour (Max 100 characters)",
                              hintStyle: TextStyle(
                                fontWeight: FontWeight.normal,
                              ),
                              border: InputBorder.none),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              CustomCard(
                height: 120,
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Pet Description",
                        style: pinkHeadingStyle,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0, right: 10),
                        child: TextFormField(
                          controller: petDescription,
                          validator: (value){
                            return value.isEmpty ? "Required Field" : null;
                          },
                          textInputAction: TextInputAction.next,
                          maxLength: 100,
                          buildCounter: (context,
                                  {currentLength, isFocused, maxLength}) =>
                              null,
                          decoration: InputDecoration(
                              hintText: description ?? "Enter Description (Max 100 characters)",
                              hintStyle: TextStyle(
                                fontWeight: FontWeight.normal,
                              ),
                              border: InputBorder.none),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              CustomCard(
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.only(left:12.0, top:14),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Owner Firstname",
                        style: pinkHeadingStyle,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left:4.0, right:10),
                        child: TextFormField(
                          controller: userFirstname,
                          validator: (value){
                            return value.isEmpty ? "Required Field" : null;
                          },
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                              hintText: firstName,
                              hintStyle: TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                              border: InputBorder.none),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              CustomCard(
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.only(left:12.0, top:14),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Owner Lastname",
                        style: pinkHeadingStyle,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left:4.0, right:10),
                        child: TextFormField(
                          controller: userLastname,
                          validator: (value){
                            return value.isEmpty ? "Required Field" : null;
                          },
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                              hintText: lastName,
                              hintStyle: TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                              border: InputBorder.none),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              CustomCard(
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Owner Description",
                        style: pinkHeadingStyle,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0, right: 10),
                        child: TextFormField(
                          controller: userDescription,
                          validator: (value){
                            return value.isEmpty ? "Required Field" : null;
                          },
                          textInputAction: TextInputAction.next,
                          maxLength: 100,
                          buildCounter: (context,
                              {currentLength, isFocused, maxLength}) =>
                          null,
                          decoration: InputDecoration(
                              hintText: ownerDescription ?? "Enter Description (Max 100 characters)",
                              hintStyle: TextStyle(
                                fontWeight: FontWeight.normal,
                              ),
                              border: InputBorder.none),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              CustomCard(
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.only(top: 14.0, right: 15, left: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(
                            "Owner Age",
                            style: pinkHeadingStyle,
                          ),
                          Spacer(),
                          Text(
                            "${ownerAge.toDouble().toString()} yr.",
                            style: TextStyle(
                              color: Colors.black38,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: Colors.redAccent,
                          trackHeight: 1,
                          inactiveTrackColor: Colors.black26,
                          thumbColor: Colors.redAccent,
                          //overlayColor: Color(0x29EB1555),
                          thumbShape:
                          RoundSliderThumbShape(enabledThumbRadius: 10.0),
                          overlayShape:
                          RoundSliderOverlayShape(overlayRadius: 25.0),
                        ),
                        child: Slider(
                          value: ownerAge.toDouble(),
                          min: 15,
                          max: 100,
                          onChanged: (double newValue) {
                            setState(() {
                              ownerAge = newValue.round();
                            });
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10,),
              isLoading ? Center(child: CircularProgressIndicator(
                strokeWidth: 2,
                backgroundColor: Colors.pink,
              ),) :InkWell(
                onTap: () async{
                  if(_formKey.currentState.validate()){
                    setState(() {
                      isLoading = true;
                    });
                    FirebaseCredentials().db.collection("Pet").doc(widget.id).update(
                        {
                          'age': age,
                          'description': petDescription.text,
                          'breed' : petBreed.text,
                          'behaviour' : petBehaviour.text,
                          'name' : petName.text,
                          'sex' : gender,
                          'size' : petSize,
                        }).then((value) {
                    });
                    FirebaseCredentials().db.collection("User").doc(widget.ownerId).update(
                        {
                          'age' : ownerAge,
                          'firstName' : userFirstname.text,
                          'lastName' : userLastname.text,
                          'description' : userDescription.text,
                        }).then((value) {
                      setState(() {
                        isLoading = false;
                      });
                    });
                  }

                },
                child: CustomCard(
                  height: 60,
                  width: MediaQuery.of(context).size.width,
                  child: Center(
                    child: Text(
                      "Save Changes",
                      style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class petDropdownWidgetCard extends StatefulWidget {
  petDropdownWidgetCard({
    this.variable,
    this.title,
    this.hintText,
    this.list,
  });

  dynamic variable;
  String title;
  String hintText;
  List<String> list;

  @override
  _petDropdownWidgetCardState createState() => _petDropdownWidgetCardState();
}

class _petDropdownWidgetCardState extends State<petDropdownWidgetCard> {
  @override
  Widget build(BuildContext context) {
    return CustomCard(
      width: MediaQuery.of(context).size.width,
      height: 95,
      child: Padding(
        padding: const EdgeInsets.only(top: 12.0, left: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: pinkHeadingStyle,
            ),
            DropdownButtonFormField(
              isExpanded: false,
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                hintText: widget.hintText,
                contentPadding: EdgeInsets.all(8.0),
                hintStyle: hintTextStyle.copyWith(
                  color: Colors.black38,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(
                    color: Colors.transparent,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(
                      color: Colors.transparent,
                    )),
              ),
              value: widget.variable,
              items: widget.list
                  .map<DropdownMenuItem<String>>(
                      (String value) => DropdownMenuItem(
                            child: Text(value),
                            value: value,
                          ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  widget.variable = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

class petAgeSliderWidget extends StatefulWidget {
  petAgeSliderWidget({
    this.age,
  });

  int age;

  @override
  _petAgeSliderWidgetState createState() => _petAgeSliderWidgetState();
}

class _petAgeSliderWidgetState extends State<petAgeSliderWidget> {
  @override
  Widget build(BuildContext context) {
    return CustomCard(
      height: 100,
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.only(top: 12.0, right: 15, left: 10),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  "Preferable Age",
                  style: pinkHeadingStyle,
                ),
                Spacer(),
                Text(
                  "${widget.age.toString()} yr.",
                  style: TextStyle(
                    color: Colors.black38,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: appBarBgColor,
                trackHeight: 2,
                inactiveTrackColor: Colors.black26,
                thumbColor: Color(0xFFEB1555),
                //overlayColor: Color(0x29EB1555),
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10.0),
                overlayShape: RoundSliderOverlayShape(overlayRadius: 25.0),
              ),
              child: Slider(
                value: widget.age.toDouble(),
                min: 1,
                max: 100,
                onChanged: (double newValue) {
                  setState(() {
                    widget.age = newValue.round();
                  });
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
