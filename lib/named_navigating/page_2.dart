import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Page2 extends StatelessWidget {
  const Page2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Page 2 + name : ${Get.parameters['name']}"),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                    onPressed: () {
                      Get.back();
                    }, icon: const Icon(Icons.arrow_back_ios_outlined)),
                IconButton(
                    onPressed: () {
                      Get.toNamed("/page3", arguments: 'Arguments :D');
                    },
                    icon: const Icon(Icons.arrow_forward_ios)),
              ],
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Get.offAllNamed("/page1");
        },
        child: const Text("reset"),
      ),
    );
  }
}
