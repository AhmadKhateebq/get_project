import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../number_guess_game/number_controller.dart';

class HistoryPage extends GetView<GuessController> {
  const HistoryPage({super.key});
  // final GuessController c = Get.find();

  @override
  Widget build(BuildContext context) {
    List history = [...{...controller.history}];
    return Scaffold(
      appBar: AppBar(
        title: const Text("History page"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Your number was ${controller.guess.value}"),
            const Text("The CPU Guessed : "),
            Expanded(
              child: ListView.builder(
                itemCount: history.length+1,
                  itemBuilder: (context, index) {
                  if(index == (history.length  )){
                    return Card(
                        color: Colors.green,
                        child: ListTile(
                          leading: Text("${controller.guess.value}"),
                        ));
                  }
                    return Card(
                     color: Colors.deepOrangeAccent,
                     child: ListTile(
                       leading: Text("${history[index]}"),
                     ),
                   );
                  }
                  ),
            ),


          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.reset,
        child: const Text("Reset"),
      ),
    );
  }
}
