// // // import 'package:coyote_app/controller/ble_controller.dart';
// // // import 'package:flutter/material.dart';
// // // import 'package:get/get.dart';
// // // import 'package:get_storage/get_storage.dart';
// // // import 'theme/app_colors.dart';
// // // import 'screens/splash_screen.dart';

// // // Future<void> main() async {
// // //   WidgetsFlutterBinding.ensureInitialized();
// // //   await GetStorage.init();
// // //   Get.put<BleController>(BleController());
// // //   runApp(const CoyoteApp());
// // // }

// // // class CoyoteApp extends StatelessWidget {
// // //   const CoyoteApp({super.key});

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return GetMaterialApp(
// // //       title: 'Coyote',
// // //       debugShowCheckedModeBanner: false,
// // //       theme: ThemeData(
// // //         fontFamily: 'Poppins',
// // //         colorScheme: ColorScheme.dark(
// // //           primary: AppColors.primary,
// // //           surface: AppColors.surface,
// // //           onPrimary: AppColors.textPrimary,
// // //           onSurface: AppColors.textPrimary,
// // //         ),
// // //         scaffoldBackgroundColor: AppColors.background,
// // //       ),
// // //       home: const SplashScreen(),
// // //     );
// // //   }
// // // }

// // import 'package:coyote_app/controller/ble_controller.dart';
// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';
// // import 'package:get_storage/get_storage.dart';
// // import 'theme/app_colors.dart';
// // import 'screens/splash_screen.dart';

// // Future<void> main() async {
// //   WidgetsFlutterBinding.ensureInitialized();
// //   await GetStorage.init();
// //   Get.put<BleController>(BleController());
// //   runApp(const CoyoteApp());
// // }

// // class CoyoteApp extends StatelessWidget {
// //   const CoyoteApp({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return GetMaterialApp(
// //       title: 'Coyote',
// //       debugShowCheckedModeBanner: false,
// //       theme: ThemeData(
// //         fontFamily: 'Poppins',
// //         colorScheme: ColorScheme.dark(
// //           primary: AppColors.primary,
// //           surface: AppColors.surface,
// //           onPrimary: AppColors.textPrimary,
// //           onSurface: AppColors.textPrimary,
// //         ),
// //         scaffoldBackgroundColor: AppColors.background,
// //       ),
// //       builder: (context, child) {
// //         return MediaQuery(
// //           data: MediaQuery.of(context).copyWith(
// //             textScaler: const TextScaler.linear(1.0),
// //             boldText: false,
// //             // MediaQuery.of(
// //             //   context,
// //             // ).textScaler.clamp(minScaleFactor: 1.0, maxScaleFactor: 1.0),
// //           ),
// //           child: Builder(builder: (context) => child!),
// //         );
// //       },
// //       home: const SplashScreen(),
// //     );
// //   }
// // }

// import 'package:coyote_app/controller/ble_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'theme/app_colors.dart';
// import 'screens/splash_screen.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await GetStorage.init();
//   Get.put<BleController>(BleController());
//   runApp(const CoyoteApp());
// }

// class CoyoteApp extends StatelessWidget {
//   const CoyoteApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final view = WidgetsBinding.instance.platformDispatcher.views.first;
//     final logicalWidth = view.physicalSize.width / view.devicePixelRatio;
//     final logicalHeight = view.physicalSize.height / view.devicePixelRatio;

//     return ScreenUtilInit(
//       designSize: Size(logicalWidth, logicalHeight),
//       minTextAdapt: false,
//       splitScreenMode: false,
//       useInheritedMediaQuery: true,
//       builder: (context, child) {
//         return GetMaterialApp(
//           title: 'Coyote',
//           debugShowCheckedModeBanner: false,
//           theme: ThemeData(
//             fontFamily: 'Poppins',
//             colorScheme: ColorScheme.dark(
//               primary: AppColors.primary,
//               surface: AppColors.surface,
//               onPrimary: AppColors.textPrimary,
//               onSurface: AppColors.textPrimary,
//             ),
//             scaffoldBackgroundColor: AppColors.background,
//           ),
//           builder: (context, child) {
//             return MediaQuery(
//               data: MediaQuery.of(context).copyWith(
//                 textScaler: const TextScaler.linear(1.0),
//                 boldText: false,
//               ),
//               child: child!,
//             );
//           },
//           home: const SplashScreen(),
//         );
//       },
//     );
//   }
// }

import 'package:coyote_app/controller/ble_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'theme/app_colors.dart';
import 'screens/splash_screen.dart';

// Store baseline pixel ratio at startup
late final double _baselinePixelRatio;
late final Size _baselineSize;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Capture BEFORE any scaling happens
  final view = WidgetsBinding.instance.platformDispatcher.views.first;
  _baselinePixelRatio = view.devicePixelRatio.clamp(1.0, 2.75);
  _baselineSize = Size(
    view.physicalSize.width / _baselinePixelRatio,
    view.physicalSize.height / _baselinePixelRatio,
  );

  await GetStorage.init();
  Get.put<BleController>(BleController());
  runApp(const CoyoteApp());
}

class CoyoteApp extends StatelessWidget {
  const CoyoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Coyote',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.dark(
          primary: AppColors.primary,
          surface: AppColors.surface,
          onPrimary: AppColors.textPrimary,
          onSurface: AppColors.textPrimary,
        ),
        scaffoldBackgroundColor: AppColors.background,
      ),
      builder: (context, child) {
        final currentPixelRatio = View.of(context).devicePixelRatio;
        final scale = _baselinePixelRatio / currentPixelRatio;
        final mediaQuery = MediaQuery.of(context);

        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: const TextScaler.linear(1.0),
            boldText: false,
          ),
          child: FractionallySizedBox(
            widthFactor: 1 / scale,
            heightFactor: 1 / scale,
            child: Transform.scale(scale: scale, child: child!),
          ),
        );
      },
      home: const SplashScreen(),
    );
  }
}
