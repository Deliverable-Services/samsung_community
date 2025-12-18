import 'package:get/get.dart';

class VodController extends GetxController {
  /// Currently selected filter index:
  /// 0 = All, 1 = VOD, 2 = Podcasts
  final RxInt selectedFilterIndex = 0.obs;

  void setFilter(int index) {
    selectedFilterIndex.value = index;
  }
}
