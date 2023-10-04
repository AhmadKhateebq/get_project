import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Page3 extends StatelessWidget {
  const Page3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(Get.arguments!!),
            const Text("Page 3"),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                    onPressed: () {
                      Get.back();
                    }, icon: const Icon(Icons.arrow_back_ios_outlined)),
                IconButton(onPressed: (){Get.toNamed("/page1/123");}, icon: const Icon(Icons.arrow_forward_ios)),
                IconButton(onPressed: (){Get.toNamed("/page1");}, icon: const Icon(Icons.arrow_forward)),
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
