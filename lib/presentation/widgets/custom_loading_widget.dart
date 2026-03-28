import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<dynamic> customLoadingWidget({required BuildContext context, String? title}){
  return showDialog(context: context, builder: (context) => Center(child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisSize: MainAxisSize.min,
    children: [
      CircularProgressIndicator(),
      Text(title ?? "Loading" ,style: TextStyle(color:Colors.red),)
    ],
  )));
}