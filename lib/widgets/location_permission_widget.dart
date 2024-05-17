import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class locationPermissionAlertDialogu extends StatelessWidget {
  const locationPermissionAlertDialogu({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: const Text('Location Service Required', style: TextStyle(
        color: Colors.black,
        fontFamily: 'Ubuntu',
        fontWeight: FontWeight.bold
      )),
      content: const Text('Current Location Required To Fetch Weather', style: TextStyle(
        color: Colors.black,
        fontFamily: 'Ubuntu',
        fontWeight: FontWeight.bold
      )),
      actions: <Widget>[
        TextButton(
          child: const Text('OK', textAlign: TextAlign.center,style: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold
          ),),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
        ),
        TextButton(
          child: const Text('Cancel', textAlign: TextAlign.center,style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold
          ),),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        ),
      ],
    );
  }
}
