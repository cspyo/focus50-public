import 'package:flutter/material.dart';
import 'package:focus50/consts/routes.dart';
import 'package:get/route_manager.dart';

class AppRouterDelegate extends GetDelegate {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      onPopPage: (route, result) => route.didPop(result),
      pages: currentConfiguration != null
          ? [currentConfiguration!.currentPage!]
          : [GetNavConfig.fromRoute(Routes.ABOUT)!.currentPage!],
    );
  }
}
