import 'package:flutter/cupertino.dart';

import 'ConstForResponsive.dart';

class ResponsiveLayout extends StatelessWidget {


  final Widget mobilebody;
  final Widget desktopbody;
  
  const ResponsiveLayout({
    super.key,
    required this.mobilebody,
    required this.desktopbody
    });

  static bool isMobile  (BuildContext context)=>
    MediaQuery.sizeOf(context).width<600;

  static bool isDesktop (BuildContext context)=>
      MediaQuery.sizeOf(context).width<1280 &&
          MediaQuery.sizeOf(context).width<904;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    if (size.width >= DesktopWidh) {
      return desktopbody;
    } else {
      return mobilebody;
    }
  }
}
