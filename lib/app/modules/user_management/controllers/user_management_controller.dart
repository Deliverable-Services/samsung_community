import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../repository/user_repo/user_repo.dart';
import '../../../data/models/user_model.dart';
import '../../../data/core/utils/common_snackbar.dart';
import '../../../data/core/utils/result.dart';

class UserManagementController extends GetxController {
  final UserRepo _userRepo = UserRepo();
  
  final RxList<UserModel> pendingUsers = <UserModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPendingUsers();
  }

  Future<void> fetchPendingUsers() async {
    isLoading.value = true;
    final result = await _userRepo.getPendingUsers();
    
    if (result.isSuccess) {
      pendingUsers.assignAll(result.dataOrNull ?? []);
    } else {
      CommonSnackbar.error(result.errorOrNull ?? 'Failed to fetch users');
    }
    isLoading.value = false;
  }

  Future<void> approveUser(UserModel user) async {
    // Optimistic update
    pendingUsers.remove(user);
    
    final result = await _userRepo.updateUserStatus(user.id, UserStatus.approved);
    
    if (!result.isSuccess) {
      // Revert if failed
      pendingUsers.add(user);
      CommonSnackbar.error(result.errorOrNull ?? 'Failed to approve user');
    } else {
      CommonSnackbar.success('User approved successfully');
    }
  }

  Future<void> rejectUser(UserModel user) async {
     // Optimistic update
    pendingUsers.remove(user);

    final result = await _userRepo.updateUserStatus(user.id, UserStatus.rejected);
    
    if (!result.isSuccess) {
      // Revert if failed
      pendingUsers.add(user);
      CommonSnackbar.error(result.errorOrNull ?? 'Failed to reject user');
    } else {
      CommonSnackbar.success('User rejected successfully');
    }
  }
}
