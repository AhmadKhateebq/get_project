import 'dart:math';

import 'package:get/get.dart';
import 'package:get_project/get_counter/results.dart';

class GuessController extends GetxController with StateMixin<int>{
  var guess = 0.obs;
  List<int> history = [];
  int _upperLimit = 100;
  int _lowerLimit = 0;
  GuessController(){
    _guess();
  }

  reset(){
    _lowerLimit = 0;
    _upperLimit = 100;
    history = [];
    Get.back();
  }
  upper(){
    _lowerLimit = guess.value;
    if((_upperLimit - _lowerLimit) == 1){
      guess.value = _upperLimit;
      return;
    }else{
      _guess();
    }
  }
  lower(){
    _upperLimit = guess.value;
    if((_upperLimit - _lowerLimit) == 1){
      guess.value = _lowerLimit;
      return;
    }else{
      _guess();
    }

  }
  equal(){
    Get.to(() => const HistoryPage());
  }
  _guess(){
    history.add(guess.value);
    if(_upperLimit != _lowerLimit){
      guess.value = Random().nextInt(_upperLimit - _lowerLimit)+_lowerLimit;
    }
  }
}
