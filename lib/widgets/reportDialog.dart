import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ReportDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      elevation: 5,
      insetPadding: EdgeInsets.all(10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        height: 310,
        width: 330,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.close_sharp,
                color: Colors.black38,
              ),
            ),
            Center(
              child: Text(
                "Report User",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.w900),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                height: 110,
                width: 300,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.black26,
                  ),
                ),
                child: Center(
                  child: TextFormField(
                    buildCounter: (context,
                            {currentLength, isFocused, maxLength}) =>
                        null,
                    maxLength: 200,
                    cursorHeight: 1.2,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      hintText: "Enter Your Reason(within 200 letter)",
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ),
            Center(
              child: InkWell(
                onTap: () {
                  send();

                },
                child: Container(
                  height: 60,
                  width: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.red[800],
                  ),
                  child: Center(
                    child: Text(
                      "Submit",
                      style: TextStyle(color: Colors.white, fontSize: 17),
                    ),
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
    );
  }
  Future<void> send() async {

    final Email email = Email(
      body: 'Pet tag ',
      subject: 'Reason',
      recipients: ["umarch007.uc@gmail.com"],
      attachmentPaths: null,
      isHTML: false,
    );

    String platformResponse;

    try {
      await FlutterEmailSender.send(email).then((value)
      {
        print('Email is Sent');
        String status = 'Send';
        platformResponse = 'Reason email sent to Passenger';

        // FirebaseFirestore.instance.collection('hourlyBooking').doc(widget.bookingId).update({'invoiceStatus' : status}).then((value)
        // {
        //   Navigator.of(context).pop();
        //   Navigator.of(context).pop();
        // });

      });
    } catch (error) {
      platformResponse = error.toString();
    }

    // if (!mounted) return;

    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     content: Text(platformResponse),
    //   ),
    // );

  }
}
