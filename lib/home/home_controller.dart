import 'package:apper/auth/login_controller.dart';

import 'package:get/get.dart';

class HomeController extends GetxController {
  final loginController = Get.put(LoginController());
  var username = "".obs;

  getUsername() {
    username.value = loginController.username.value;
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();

    getUsername();
  }
}
