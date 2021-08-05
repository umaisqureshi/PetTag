import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UploadImageDialog extends StatefulWidget {
  @override
  _UploadImageDialogState createState() => _UploadImageDialogState();
}

class _UploadImageDialogState extends State<UploadImageDialog> {
  ImagePicker imagePicker = ImagePicker();
  PickedFile  imageFile;

  void _openGallery(BuildContext context) async {
    var picture = await imagePicker.getImage(source: ImageSource.gallery);
    this.setState(() {
      imageFile = picture;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      elevation: 5,
      child: Container(
        height: 150,
        width: 350,
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10.0, top: 10),
              child: Text(
                "Upload Image",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Text(
                "Select a Photo..",
                style: TextStyle(
                  fontSize: 15,
                ),
              ),
            ),
            Spacer(),
            Row(
              children: [
                FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  padding: EdgeInsets.all(0),
                  child: Text(
                    "CANCEL",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                Spacer(),
                FlatButton(
                  onPressed: () async{

                  },
                  padding: EdgeInsets.all(0),
                  child: Text(
                    "GALLERY",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                FlatButton(
                  onPressed: () {},
                  padding: EdgeInsets.all(0),
                  child: Text(
                    "CAMERA",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
