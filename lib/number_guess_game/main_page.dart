import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_project/number_guess_game/number_controller.dart';
import 'package:loading_indicator/loading_indicator.dart';

class MainPage extends GetView<GuessController> {
  const MainPage({super.key});

  @override
  Widget build(context) {
    if (kDebugMode) {
      print("start of build method");
    }
    return controller.obx(
      onLoading: Scaffold(
        body: Center(
          child: Stack(alignment: Alignment.center, children: [
            const LoadingIndicator(
              indicatorType: Indicator.ballScale,
              colors: [Colors.deepOrangeAccent],
            ),
            TextButton(
                onPressed: () {
                  controller.change(0, status: RxStatus.success());
                },
                child: const Text(
                  "Play",
                  style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      color: Colors.white),
                ))
          ]),
        ),
      ),
      (state) => Scaffold(
        appBar: AppBar(title: const Text("Guide the CPU to guess your number")),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
                color: (Colors.blueGrey),
                width: 100,
                height: 100,
                child: Center(
                  child: Obx(() => Text(
                        " ${controller.guess}",
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 50),
                      )),
                )),
            const SizedBox(
              height: 50,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                    onPressed: controller.lower,
                    icon: const Icon(Icons.arrow_downward)),
                const SizedBox(
                  width: 20,
                ),
                FloatingActionButton(
                    onPressed: controller.equal,
                    child: const Text(
                      "=",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    )),
                const SizedBox(
                  width: 20,
                ),
                IconButton(
                    onPressed: controller.upper,
                    icon: const Icon(Icons.arrow_upward))
              ],
            ),
          ],
        ),
      ),
    );
  }
}

main() {
  getPut(2);
  if (kDebugMode) {
    print("runApp after put");
  }
  runApp(GetMaterialApp(
    theme: ThemeData.dark(),
    title: "Guess Game",
    home: const MainPage(),
  ));
}

///* 1 for put
///* 2 for lazyPut
///* 3 for create
///* 4 for putAsync
///
getPut(int i) {
  switch (i) {
    case 3:
      Get.create(
        () => GuessController(),
      );
    case 1:
      Get.put(
        GuessController(),
      );
    case 2:
      Get.lazyPut<GuessController>(() => GuessController());
    case 4:
      Get.putAsync(
        () async => GuessController(),
      );
  }
}
