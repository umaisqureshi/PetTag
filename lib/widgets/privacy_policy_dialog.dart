import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PrivacyPolicyDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Material(
              child: Container(
                color: Colors.white,
                height: 400,
                width: double.infinity,
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            height: 80,
                            width: 80,
                            child: Image.asset(
                              "assets/logo@3xUpdated.png",
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            "Privacy Policy",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            height: 255,
                            child: SingleChildScrollView(
                              padding: EdgeInsets.symmetric(horizontal: 25),
                              scrollDirection: Axis.vertical,
                              child: Text(
                                "The privacy policy ('Policy') describes how MyTag LLC ('MyTag LLC','we','us' or 'our') collects, protects and uses the personally identifiable information ('Personal Information') you ('User','you' or 'your') may provide in the Pet-Tag mobile application and any of it's products or services (collectively, 'Mobile Application' or 'Services'). It also describes the choices available to you regarding our use of your Personal Information and how you can access and update this information. This Policy does not apply to the practices of companies that we do not own or control, or to individuals that we do not employ or maintain.",
                                style: TextStyle(
                                    color: Colors.pink[900], height: 1.5),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                        top: 10,
                        right: 10,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              height: 25,
                              width: 25,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  color: Colors.black),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Icon(
                                Icons.cancel_rounded,
                                color: Colors.white,
                                size: 30,
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
      ),
    );
  }
}
