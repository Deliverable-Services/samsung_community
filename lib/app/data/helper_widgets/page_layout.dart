import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_colors.dart';
import 'bottom_nav_bar.dart';
import 'device_not_supported_overlay.dart';
import 'device_service.dart';
import 'navbar.dart';

class PageLayout extends StatefulWidget {
  final Widget child;
  final int totalPoints;
  final EdgeInsets? padding;
  final bool showOverlay;
  final Widget? overlayContent;

  const PageLayout({
    super.key,
    required this.child,
    required this.totalPoints,
    this.padding,
    this.showOverlay = true,
    this.overlayContent,
  });

  @override
  State<PageLayout> createState() => _PageLayoutState();
}

class _PageLayoutState extends State<PageLayout> {
  bool _isSamsungDevice = false;
  bool _isCheckingDevice = true;

  @override
  void initState() {
    super.initState();
    _checkDevice();
  }

  Future<void> _checkDevice() async {
    final isSamsung = await DeviceService.isSamsungDevice();
    if (mounted) {
      setState(() {
        _isSamsungDevice = isSamsung;
        _isCheckingDevice = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // final shouldShowOverlay =  widget.showOverlay && !_isSamsungDevice;
    final shouldShowOverlay = false;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        top: true,
        bottom: true,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 16.h,
                  ),
                  child: Navbar(totalPoints: widget.totalPoints),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: widget.padding != null
                        ? Padding(padding: widget.padding!, child: widget.child)
                        : widget.child,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 9.w,
                    vertical: 16.h,
                  ),
                  child: BottomNavBar(),
                ),
              ],
            ),
            if (shouldShowOverlay && !_isCheckingDevice)
              Positioned.fill(
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        // Overlay background - can be used to dismiss if needed
                      },
                      child: Container(color: AppColors.overlayBackground),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: EdgeInsets.all(20.w), // padding: 20px
                        decoration: BoxDecoration(
                          color:
                              AppColors.overlayContainerBackground, // #292E36
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(
                              30.r,
                            ), // border-top-left-radius: 30px
                            topRight: Radius.circular(
                              30.r,
                            ), // border-top-right-radius: 30px
                          ),
                          boxShadow: [
                            BoxShadow(
                              offset: Offset(0, -6.h), // 0px -6px
                              blurRadius: 50.r, // 50px
                              spreadRadius: 0,
                              color:
                                  AppColors.overlayContainerShadow, // #0000004D
                            ),
                          ],
                        ),
                        child:
                            widget.overlayContent ??
                            const DeviceNotSupportedOverlay(),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
