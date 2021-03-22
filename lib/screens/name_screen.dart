import 'package:flutter/material.dart';
import 'package:reaction_lab/res/custom_colors.dart';
import 'dashboard_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NameScreen extends StatelessWidget {
  final User user;
  const NameScreen({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.orangeLight,
      appBar: AppBar(
        title: Text("Reaca"),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(padding: const EdgeInsets.all(10.0),
              child: TextField(
              )
              ),
              Padding(padding: const EdgeInsets.all(3.0),
              child: ElevatedButton(
                onPressed: (){
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => DashboardScreen(user : user,))
                  );
                },
                child: Text("Go to Dashboard"),),
              )
            ],
          ),
        ),),
    );
  }
}
