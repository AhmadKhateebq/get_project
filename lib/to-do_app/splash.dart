import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get_project/to-do_app/state_controller.dart';
import 'package:loading_indicator/loading_indicator.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Stack(alignment: Alignment.center, children: [
          LoadingIndicator(
            indicatorType: Indicator.ballScale,
            colors: [Colors.deepOrangeAccent],
          ),
          Text(
            "Loading",
            style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                color: Colors.white),
          )
        ]),
      ),
    );
  }
}
