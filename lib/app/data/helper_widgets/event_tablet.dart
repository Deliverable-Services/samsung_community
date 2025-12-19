import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EventTablet extends StatefulWidget {
  final String? text;
  final Widget? widget;
  final VoidCallback? onTap;
  final EdgeInsets? extraPadding;

  const EventTablet({
    super.key,
    this.text,
    this.widget,
    this.onTap,
    this.extraPadding,
  }) : assert(
         (text != null && widget == null) || (text == null && widget != null),
         'Either text or widget must be provided, but not both',
       );

  @override
  State<EventTablet> createState() => _EventTabletState();
}

class _EventTabletState extends State<EventTablet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap != null) {
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.onTap != null) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.onTap != null ? _scaleAnimation.value : 1.0,
            child: child!,
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100.r),
            boxShadow: [
              // Multiple outer shadows
              BoxShadow(
                color: const Color(0xFF000000).withOpacity(0.1),
                offset: Offset(0, 7.43.h),
                blurRadius: 16.6.r,
                spreadRadius: 0,
              ),
              BoxShadow(
                color: const Color(0xFF000000).withOpacity(0.09),
                offset: Offset(0, 30.15.h),
                blurRadius: 30.15.r,
                spreadRadius: 0,
              ),
              BoxShadow(
                color: const Color(0xFF000000).withOpacity(0.05),
                offset: Offset(0, 68.16.h),
                blurRadius: 41.07.r,
                spreadRadius: 0,
              ),
              BoxShadow(
                color: const Color(0xFF000000).withOpacity(0.01),
                offset: Offset(0, 121.02.h),
                blurRadius: 48.5.r,
                spreadRadius: 0,
              ),
              BoxShadow(
                color: const Color(0xFF000000).withOpacity(0.0),
                offset: Offset(0, 189.18.h),
                blurRadius: 52.87.r,
                spreadRadius: 0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100.r),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 7.864322662353516,
                sigmaY: 7.864322662353516,
              ),
              child: Stack(
                children: [
                  // Gradient border
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100.r),
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color.fromRGBO(242, 242, 242, 0.2),
                          Color.fromRGBO(129, 129, 129, 0.2),
                          Color.fromRGBO(255, 255, 255, 0.2),
                        ],
                        stops: [0.0, 0.4142, 1.0],
                      ),
                    ),
                  ),
                  // Inner container with background gradient
                  Padding(
                    padding: EdgeInsets.all(0.w),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100.r),
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color.fromRGBO(214, 214, 214, 0.4),
                            Color.fromRGBO(112, 112, 112, 0.4),
                          ],
                          stops: [0.0, 1.0],
                        ),
                      ),
                      padding: EdgeInsets.fromLTRB(
                        22.w + (widget.extraPadding?.left ?? 0),
                        12.h + (widget.extraPadding?.top ?? 0),
                        22.w + (widget.extraPadding?.right ?? 0),
                        12.h + (widget.extraPadding?.bottom ?? 0),
                      ),
                      child: Stack(
                        children: [
                          // Inset shadow effect using gradient overlay
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100.r),
                              gradient: LinearGradient(
                                begin: Alignment.topRight,
                                end: Alignment.bottomLeft,
                                colors: [
                                  const Color(0xFF000000).withOpacity(0.25),
                                  Colors.transparent,
                                ],
                                stops: const [0.0, 0.3],
                              ),
                            ),
                          ),
                          // Text or Widget
                          Center(
                            child: widget.text != null
                                ? Text(
                                    widget.text!,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12.sp,
                                      height: 1,
                                      letterSpacing: 0,
                                      color: Colors.white,
                                    ),
                                    textScaler: const TextScaler.linear(1.0),
                                  )
                                : widget.widget!,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
