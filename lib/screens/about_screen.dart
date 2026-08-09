// // // // // // import 'package:flutter/material.dart';
// // // // // // import 'package:flutter_svg/flutter_svg.dart';
// // // // // // import 'package:youtube_player_flutter/youtube_player_flutter.dart';
// // // // // // import '../theme/app_colors.dart';
// // // // // // import '../components/components.dart';

// // // // // // /// About screen showing help / tutorial videos.
// // // // // // class AboutScreen extends StatelessWidget {
// // // // // //   const AboutScreen({super.key});

// // // // // //   @override
// // // // // //   Widget build(BuildContext context) {
// // // // // //     return Scaffold(
// // // // // //       body: CoyoteBackground(
// // // // // //         child: SafeArea(
// // // // // //           child: SingleChildScrollView(
// // // // // //             padding: const EdgeInsets.symmetric(horizontal: 24),
// // // // // //             child: Column(
// // // // // //               crossAxisAlignment: CrossAxisAlignment.start,
// // // // // //               children: [
// // // // // //                 SizedBox(height: 24),
// // // // // //                 _AboutHeader(),
// // // // // //                 SizedBox(height: 28),
// // // // // //                 _VideoCard(
// // // // // //                   title: 'New SmartPuck App V2',
// // // // // //                   description:
// // // // // //                       'Learn how to run your SmartPuck App. This video will guide you through the app controls to operate and set up your SmartPuck.',
// // // // // //                   thumbnailAsset: 'assets/images/about1.svg',
// // // // // //                 ),
// // // // // //                 SizedBox(height: 20),
// // // // // //                 _VideoCard(
// // // // // //                   title: 'App Trouble Shooting',
// // // // // //                   description:
// // // // // //                       'Learn how to run your SmartPuck App. This video will guide you through the app controls to operate and set up your SmartPuck.',
// // // // // //                   thumbnailAsset: 'assets/images/about1.svg',
// // // // // //                 ),
// // // // // //                 SizedBox(height: 24),
// // // // // //                 // SvgPicture.asset("assets/images/about1.svg"),
// // // // // //               ],
// // // // // //             ),
// // // // // //           ),
// // // // // //         ),
// // // // // //       ),
// // // // // //     );
// // // // // //   }
// // // // // // }

// // // // // // class _AboutHeader extends StatelessWidget {
// // // // // //   const _AboutHeader();

// // // // // //   @override
// // // // // //   Widget build(BuildContext context) {
// // // // // //     return Text(
// // // // // //       'About',
// // // // // //       style: const TextStyle(
// // // // // //         fontFamily: 'cy_grotesk',
// // // // // //         fontSize: 25,
// // // // // //         fontWeight: FontWeight.w400,
// // // // // //         color: AppColors.textPrimary,
// // // // // //         // decoration: TextDecoration.underline,
// // // // // //         // decorationThickness: 2,
// // // // // //       ),
// // // // // //     );
// // // // // //   }
// // // // // // }

// // // // // // class _VideoCard extends StatefulWidget {
// // // // // //   const _VideoCard({
// // // // // //     required this.title,
// // // // // //     required this.description,
// // // // // //     required this.thumbnailAsset,
// // // // // //   });

// // // // // //   final String title;
// // // // // //   final String description;
// // // // // //   final String thumbnailAsset;

// // // // // //   @override
// // // // // //   State<_VideoCard> createState() => _VideoCardState();
// // // // // // }

// // // // // // class _VideoCardState extends State<_VideoCard> {
// // // // // //   // final videoId = YoutubePlayer.convertUrlToId(
// // // // // //   //   'https://www.youtube.com/watch?v=BBAyRBTfsOU',
// // // // // //   // );

// // // // // //   final controller = YoutubePlayerController(
// // // // // //     initialVideoId: "BBAyRBTfsOU",
// // // // // //     flags: const YoutubePlayerFlags(autoPlay: true, mute: false),
// // // // // //   );

// // // // // //   @override
// // // // // //   void dispose() {
// // // // // //     controller.dispose();
// // // // // //     super.dispose();
// // // // // //   }

// // // // // //   @override
// // // // // //   Widget build(BuildContext context) {
// // // // // //     return Container(
// // // // // //       decoration: BoxDecoration(
// // // // // //         color: AppColors.segmentContainer,
// // // // // //         borderRadius: BorderRadius.circular(28),
// // // // // //         border: Border.all(color: Colors.white.withOpacity(0.06)),
// // // // // //       ),
// // // // // //       padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
// // // // // //       child: Column(
// // // // // //         crossAxisAlignment: CrossAxisAlignment.start,
// // // // // //         children: [
// // // // // //           Text(
// // // // // //             widget.title,
// // // // // //             style: const TextStyle(
// // // // // //               fontSize: 16,
// // // // // //               fontWeight: FontWeight.w500,
// // // // // //               color: AppColors.textPrimary,
// // // // // //             ),
// // // // // //           ),
// // // // // //           const SizedBox(height: 8),
// // // // // //           Text(
// // // // // //             widget.description,
// // // // // //             style: const TextStyle(
// // // // // //               fontSize: 12,
// // // // // //               height: 1.4,
// // // // // //               fontWeight: FontWeight.w400,
// // // // // //               color: AppColors.textMuted,
// // // // // //             ),
// // // // // //           ),
// // // // // //           const SizedBox(height: 16),

// // // // // //           // YoutubePlayer(
// // // // // //           //   controller: controller,
// // // // // //           //   showVideoProgressIndicator: true,
// // // // // //           //   progressIndicatorColor: Colors.red,
// // // // // //           // ),
// // // // // //           ClipRRect(
// // // // // //             borderRadius: BorderRadius.circular(22),
// // // // // //             child: AspectRatio(
// // // // // //               aspectRatio: 16 / 9,
// // // // // //               child: Stack(
// // // // // //                 fit: StackFit.expand,
// // // // // //                 children: [
// // // // // //                   // Image.asset("assets/images/about_test.png", fit: BoxFit.fill),
// // // // // //                   // SvgPicture.asset(thumbnailAsset, height: 50),
// // // // // //                   // YoutubePlayerBuilder(
// // // // // //                   //   player: YoutubePlayer(controller: controller),
// // // // // //                   //   builder: (context, player) {
// // // // // //                   //     return Scaffold(
// // // // // //                   //       body: Column(
// // // // // //                   //         children: [
// // // // // //                   //           player,
// // // // // //                   //           // rest of your screen
// // // // // //                   //         ],
// // // // // //                   //       ),
// // // // // //                   //     );
// // // // // //                   //   },
// // // // // //                   // ),
// // // // // //                   YoutubePlayer(
// // // // // //             controller: controller,
// // // // // //             showVideoProgressIndicator: true,
// // // // // //             progressIndicatorColor: Colors.red,

// // // // // //           ),
// // // // // //                   Container(
// // // // // //                     decoration: BoxDecoration(
// // // // // //                       gradient: LinearGradient(
// // // // // //                         begin: Alignment.topCenter,
// // // // // //                         end: Alignment.bottomCenter,
// // // // // //                         colors: [
// // // // // //                           Colors.black.withOpacity(0.05),
// // // // // //                           Colors.black.withOpacity(0.35),
// // // // // //                         ],
// // // // // //                       ),
// // // // // //                     ),
// // // // // //                   ),
// // // // // //                   // Center(
// // // // // //                   //   child: Container(
// // // // // //                   //     width: 64,
// // // // // //                   //     height: 64,
// // // // // //                   //     decoration: BoxDecoration(
// // // // // //                   //       shape: BoxShape.circle,
// // // // // //                   //       color: Colors.white.withOpacity(0.85),
// // // // // //                   //       boxShadow: [
// // // // // //                   //         BoxShadow(
// // // // // //                   //           color: Colors.black.withOpacity(0.3),
// // // // // //                   //           blurRadius: 10,
// // // // // //                   //           offset: const Offset(0, 4),
// // // // // //                   //         ),
// // // // // //                   //       ],
// // // // // //                   //     ),
// // // // // //                   //     child: const Icon(
// // // // // //                   //       Icons.play_arrow_rounded,
// // // // // //                   //       size: 36,
// // // // // //                   //       color: AppColors.primary,
// // // // // //                   //     ),
// // // // // //                   //   ),
// // // // // //                   // ),
// // // // // //                 ],
// // // // // //               ),
// // // // // //             ),
// // // // // //           ),
// // // // // //         ],
// // // // // //       ),
// // // // // //     );
// // // // // //   }
// // // // // // }

// // // // // import 'package:flutter/material.dart';
// // // // // import 'package:youtube_player_flutter/youtube_player_flutter.dart';
// // // // // import '../theme/app_colors.dart';
// // // // // import '../components/components.dart';

// // // // // /// About screen showing a help / tutorial video.
// // // // // class AboutScreen extends StatelessWidget {
// // // // //   const AboutScreen({super.key});

// // // // //   @override
// // // // //   Widget build(BuildContext context) {
// // // // //     return Scaffold(
// // // // //       body: CoyoteBackground(
// // // // //         child: SafeArea(
// // // // //           child: SingleChildScrollView(
// // // // //             padding: const EdgeInsets.symmetric(horizontal: 24),
// // // // //             child: Column(
// // // // //               crossAxisAlignment: CrossAxisAlignment.start,
// // // // //               children: const [
// // // // //                 SizedBox(height: 24),
// // // // //                 _AboutHeader(),
// // // // //                 SizedBox(height: 28),
// // // // //                 _VideoCard(
// // // // //                   title: 'New SmartPuck App V2',
// // // // //                   description:
// // // // //                       'Learn how to run your SmartPuck App. This video will guide you through the app controls to operate and set up your SmartPuck.',
// // // // //                   videoId: 'ywDT-lFnApQ',
// // // // //                 ),
// // // // //                 SizedBox(height: 24),
// // // // //               ],
// // // // //             ),
// // // // //           ),
// // // // //         ),
// // // // //       ),
// // // // //     );
// // // // //   }
// // // // // }

// // // // // class _AboutHeader extends StatelessWidget {
// // // // //   const _AboutHeader();

// // // // //   @override
// // // // //   Widget build(BuildContext context) {
// // // // //     return const Text(
// // // // //       'About',
// // // // //       style: TextStyle(
// // // // //         fontFamily: 'cy_grotesk',
// // // // //         fontSize: 25,
// // // // //         fontWeight: FontWeight.w400,
// // // // //         color: AppColors.textPrimary,
// // // // //       ),
// // // // //     );
// // // // //   }
// // // // // }

// // // // // class _VideoCard extends StatefulWidget {
// // // // //   const _VideoCard({
// // // // //     required this.title,
// // // // //     required this.description,
// // // // //     required this.videoId,
// // // // //   });

// // // // //   final String title;
// // // // //   final String description;
// // // // //   final String videoId;

// // // // //   @override
// // // // //   State<_VideoCard> createState() => _VideoCardState();
// // // // // }

// // // // // class _VideoCardState extends State<_VideoCard> {
// // // // //   late final YoutubePlayerController controller;

// // // // //   @override
// // // // //   void initState() {
// // // // //     super.initState();
// // // // //     controller = YoutubePlayerController(
// // // // //       initialVideoId: widget.videoId,
// // // // //       flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
// // // // //     );
// // // // //   }

// // // // //   @override
// // // // //   void dispose() {
// // // // //     controller.dispose();
// // // // //     super.dispose();
// // // // //   }

// // // // //   @override
// // // // //   Widget build(BuildContext context) {
// // // // //     return Container(
// // // // //       decoration: BoxDecoration(
// // // // //         color: AppColors.segmentContainer,
// // // // //         borderRadius: BorderRadius.circular(28),
// // // // //         border: Border.all(color: Colors.white.withOpacity(0.06)),
// // // // //       ),
// // // // //       padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
// // // // //       child: Column(
// // // // //         crossAxisAlignment: CrossAxisAlignment.start,
// // // // //         children: [
// // // // //           Text(
// // // // //             widget.title,
// // // // //             style: const TextStyle(
// // // // //               fontSize: 16,
// // // // //               fontWeight: FontWeight.w500,
// // // // //               color: AppColors.textPrimary,
// // // // //             ),
// // // // //           ),
// // // // //           const SizedBox(height: 8),
// // // // //           Text(
// // // // //             widget.description,
// // // // //             style: const TextStyle(
// // // // //               fontSize: 12,
// // // // //               height: 1.4,
// // // // //               fontWeight: FontWeight.w400,
// // // // //               color: AppColors.textMuted,
// // // // //             ),
// // // // //           ),
// // // // //           const SizedBox(height: 16),
// // // // //           ClipRRect(
// // // // //             borderRadius: BorderRadius.circular(22),
// // // // //             child: AspectRatio(
// // // // //               aspectRatio: 9 / 12,
// // // // //               child: YoutubePlayer(
// // // // //                 controller: controller,
// // // // //                 showVideoProgressIndicator: true,
// // // // //                 progressIndicatorColor: Colors.red,
// // // // //               ),
// // // // //             ),
// // // // //           ),
// // // // //         ],
// // // // //       ),
// // // // //     );
// // // // //   }
// // // // // }

// // // // import 'package:flutter/material.dart';
// // // // import 'package:youtube_player_flutter/youtube_player_flutter.dart';
// // // // import '../theme/app_colors.dart';
// // // // import '../components/components.dart';

// // // // /// About screen showing a help / tutorial video.
// // // // ///
// // // // /// Tapping play on the embedded video automatically expands it to
// // // // /// fullscreen. The player's own control bar exposes an exit-fullscreen
// // // // /// button once in fullscreen mode.
// // // // class AboutScreen extends StatefulWidget {
// // // //   const AboutScreen({super.key});

// // // //   @override
// // // //   State<AboutScreen> createState() => _AboutScreenState();
// // // // }

// // // // class _AboutScreenState extends State<AboutScreen> {
// // // //   late final YoutubePlayerController _controller;

// // // //   @override
// // // //   void initState() {
// // // //     super.initState();
// // // //     _controller = YoutubePlayerController(
// // // //       initialVideoId: 'ywDT-lFnApQ',
// // // //       flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
// // // //     )..addListener(_onPlayerStateChange);
// // // //   }

// // // //   void _onPlayerStateChange() {
// // // //     // As soon as playback starts, jump into fullscreen. The player itself
// // // //     // handles switching that same control back to "exit fullscreen".
// // // //     if (_controller.value.isPlaying && !_controller.value.isFullScreen) {
// // // //       _controller.toggleFullScreenMode();
// // // //     }
// // // //   }

// // // //   @override
// // // //   void dispose() {
// // // //     _controller.removeListener(_onPlayerStateChange);
// // // //     _controller.dispose();
// // // //     super.dispose();
// // // //   }

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return YoutubePlayerBuilder(
// // // //       player: YoutubePlayer(
// // // //         controller: _controller,
// // // //         showVideoProgressIndicator: true,
// // // //         progressIndicatorColor: Colors.red,
// // // //       ),
// // // //       builder: (context, player) {
// // // //         return Scaffold(
// // // //           body: CoyoteBackground(
// // // //             child: SafeArea(
// // // //               child: SingleChildScrollView(
// // // //                 padding: const EdgeInsets.symmetric(horizontal: 24),
// // // //                 child: Column(
// // // //                   crossAxisAlignment: CrossAxisAlignment.start,
// // // //                   children: [
// // // //                     const SizedBox(height: 24),
// // // //                     const _AboutHeader(),
// // // //                     const SizedBox(height: 28),
// // // //                     _VideoCard(
// // // //                       title: 'New SmartPuck App V2',
// // // //                       description:
// // // //                           'Learn how to run your SmartPuck App. This video will guide you through the app controls to operate and set up your SmartPuck.',
// // // //                       player: player,
// // // //                     ),
// // // //                     const SizedBox(height: 24),
// // // //                   ],
// // // //                 ),
// // // //               ),
// // // //             ),
// // // //           ),
// // // //         );
// // // //       },
// // // //     );
// // // //   }
// // // // }

// // // // class _AboutHeader extends StatelessWidget {
// // // //   const _AboutHeader();

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return const Text(
// // // //       'About',
// // // //       style: TextStyle(
// // // //         fontFamily: 'cy_grotesk',
// // // //         fontSize: 25,
// // // //         fontWeight: FontWeight.w400,
// // // //         color: AppColors.textPrimary,
// // // //       ),
// // // //     );
// // // //   }
// // // // }

// // // // class _VideoCard extends StatelessWidget {
// // // //   const _VideoCard({
// // // //     required this.title,
// // // //     required this.description,
// // // //     required this.player,
// // // //   });

// // // //   final String title;
// // // //   final String description;
// // // //   final Widget player;

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return Container(
// // // //       decoration: BoxDecoration(
// // // //         color: AppColors.segmentContainer,
// // // //         borderRadius: BorderRadius.circular(28),
// // // //         border: Border.all(color: Colors.white.withOpacity(0.06)),
// // // //       ),
// // // //       padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
// // // //       child: Column(
// // // //         crossAxisAlignment: CrossAxisAlignment.start,
// // // //         children: [
// // // //           Text(
// // // //             title,
// // // //             style: const TextStyle(
// // // //               fontSize: 16,
// // // //               fontWeight: FontWeight.w500,
// // // //               color: AppColors.textPrimary,
// // // //             ),
// // // //           ),
// // // //           const SizedBox(height: 8),
// // // //           Text(
// // // //             description,
// // // //             style: const TextStyle(
// // // //               fontSize: 12,
// // // //               height: 1.4,
// // // //               fontWeight: FontWeight.w400,
// // // //               color: AppColors.textMuted,
// // // //             ),
// // // //           ),
// // // //           const SizedBox(height: 16),
// // // //           ClipRRect(
// // // //             borderRadius: BorderRadius.circular(22),
// // // //             child: AspectRatio(
// // // //               aspectRatio: 16 / 9,
// // // //               child: player,
// // // //             ),
// // // //           ),
// // // //         ],
// // // //       ),
// // // //     );
// // // //   }
// // // // }

// // // import 'package:flutter/material.dart';
// // // import 'package:flutter/services.dart';
// // // import 'package:youtube_player_flutter/youtube_player_flutter.dart';
// // // import '../theme/app_colors.dart';
// // // import '../components/components.dart';

// // // /// About screen showing a help / tutorial video.
// // // ///
// // // /// Tapping play on the embedded video automatically expands it to
// // // /// fullscreen. The player's own control bar exposes an exit-fullscreen
// // // /// button once in fullscreen mode.
// // // class AboutScreen extends StatefulWidget {
// // //   const AboutScreen({super.key});

// // //   @override
// // //   State<AboutScreen> createState() => _AboutScreenState();
// // // }

// // // class _AboutScreenState extends State<AboutScreen> {
// // //   late final YoutubePlayerController _controller;

// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _controller = YoutubePlayerController(
// // //       initialVideoId: 'ywDT-lFnApQ',
// // //       flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
// // //     )..addListener(_onPlayerStateChange);
// // //   }

// // //   void _onPlayerStateChange() {
// // //     // As soon as playback starts, jump into fullscreen. The player itself
// // //     // handles switching that same control back to "exit fullscreen".
// // //     if (_controller.value.isPlaying && !_controller.value.isFullScreen) {
// // //       _controller.toggleFullScreenMode();
// // //     }
// // //   }

// // //   @override
// // //   void dispose() {
// // //     _controller.removeListener(_onPlayerStateChange);
// // //     _controller.dispose();
// // //     super.dispose();
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return YoutubePlayerBuilder(
// // //       player: YoutubePlayer(
// // //         controller: _controller,
// // //         showVideoProgressIndicator: true,
// // //         progressIndicatorColor: Colors.red,
// // //       ),
// // //       builder: (context, player) {
// // //         return Scaffold(
// // //           body: CoyoteBackground(
// // //             child: SafeArea(
// // //               child: SingleChildScrollView(
// // //                 padding: const EdgeInsets.symmetric(horizontal: 24),
// // //                 child: Column(
// // //                   crossAxisAlignment: CrossAxisAlignment.start,
// // //                   children: [
// // //                     const SizedBox(height: 24),
// // //                     const _AboutHeader(),
// // //                     const SizedBox(height: 28),
// // //                     _VideoCard(
// // //                       title: 'New SmartPuck App V2',
// // //                       description:
// // //                           'Learn how to run your SmartPuck App. This video will guide you through the app controls to operate and set up your SmartPuck.',
// // //                       player: player,
// // //                     ),
// // //                     const SizedBox(height: 24),
// // //                   ],
// // //                 ),
// // //               ),
// // //             ),
// // //           ),
// // //         );
// // //       },
// // //     );
// // //   }
// // // }

// // // class _AboutHeader extends StatelessWidget {
// // //   const _AboutHeader();

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return const Text(
// // //       'About',
// // //       style: TextStyle(
// // //         fontFamily: 'cy_grotesk',
// // //         fontSize: 25,
// // //         fontWeight: FontWeight.w400,
// // //         color: AppColors.textPrimary,
// // //       ),
// // //     );
// // //   }
// // // }

// // // class _VideoCard extends StatelessWidget {
// // //   const _VideoCard({
// // //     required this.title,
// // //     required this.description,
// // //     required this.player,
// // //   });

// // //   final String title;
// // //   final String description;
// // //   final Widget player;

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Container(
// // //       decoration: BoxDecoration(
// // //         color: AppColors.segmentContainer,
// // //         borderRadius: BorderRadius.circular(28),
// // //         border: Border.all(color: Colors.white.withOpacity(0.06)),
// // //       ),
// // //       padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
// // //       child: Column(
// // //         crossAxisAlignment: CrossAxisAlignment.start,
// // //         children: [
// // //           Text(
// // //             title,
// // //             style: const TextStyle(
// // //               fontSize: 16,
// // //               fontWeight: FontWeight.w500,
// // //               color: AppColors.textPrimary,
// // //             ),
// // //           ),
// // //           const SizedBox(height: 8),
// // //           Text(
// // //             description,
// // //             style: const TextStyle(
// // //               fontSize: 12,
// // //               height: 1.4,
// // //               fontWeight: FontWeight.w400,
// // //               color: AppColors.textMuted,
// // //             ),
// // //           ),
// // //           const SizedBox(height: 16),
// // //           ClipRRect(
// // //             borderRadius: BorderRadius.circular(22),
// // //             child: AspectRatio(
// // //               aspectRatio: 16 / 9,
// // //               child: player,
// // //             ),
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // // }
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:youtube_player_flutter/youtube_player_flutter.dart';
// // import '../theme/app_colors.dart';
// // import '../components/components.dart';

// // /// About screen showing a help / tutorial video.
// // ///
// // /// Tapping play on the embedded video automatically expands it to
// // /// fullscreen. The player's own control bar exposes an exit-fullscreen
// // /// button once in fullscreen mode.
// // class AboutScreen extends StatefulWidget {
// //   const AboutScreen({super.key});

// //   @override
// //   State<AboutScreen> createState() => _AboutScreenState();
// // }

// // class _AboutScreenState extends State<AboutScreen> {
// //   late final YoutubePlayerController _controller;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _controller = YoutubePlayerController(
// //       initialVideoId: 'ywDT-lFnApQ',
// //       flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
// //     )..addListener(_onPlayerStateChange);
// //   }

// //   bool _isFullScreen = false;

// //   void _onPlayerStateChange() {
// //     final isFullScreen = _controller.value.isFullScreen;

// //     // As soon as playback starts, jump into fullscreen. The player itself
// //     // handles switching that same control back to "exit fullscreen".
// //     if (_controller.value.isPlaying && !isFullScreen) {
// //       _controller.toggleFullScreenMode();
// //       return; // this listener fires again once isFullScreen flips to true
// //     }

// //     if (isFullScreen != _isFullScreen) {
// //       setState(() => _isFullScreen = isFullScreen);

// //       // youtube_player_flutter locks landscape by default whenever
// //       // isFullScreen becomes true. Override that so fullscreen stays
// //       // portrait, and release the lock again on exit.
// //       WidgetsBinding.instance.addPostFrameCallback((_) {
// //         SystemChrome.setPreferredOrientations(
// //           isFullScreen
// //               ? [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]
// //               : DeviceOrientation.values,
// //         );
// //       });
// //     }
// //   }

// //   @override
// //   void dispose() {
// //     _controller.removeListener(_onPlayerStateChange);
// //     _controller.dispose();
// //     super.dispose();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final screenSize = MediaQuery.of(context).size;

// //     return YoutubePlayerBuilder(
// //       player: YoutubePlayer(
// //         controller: _controller,
// //         showVideoProgressIndicator: true,
// //         progressIndicatorColor: Colors.red,
// //         // The default 16:9 box is why a portrait screen-recording looked
// //         // squeezed into a horizontal frame. Match the portrait screen's
// //         // own ratio while fullscreen instead.
// //         aspectRatio: _isFullScreen
// //             ? screenSize.width / screenSize.height
// //             : 16 / 9,
// //       ),
// //       builder: (context, player) {
// //         return Scaffold(
// //           body: CoyoteBackground(
// //             child: SafeArea(
// //               child: SingleChildScrollView(
// //                 padding: const EdgeInsets.symmetric(horizontal: 24),
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     const SizedBox(height: 24),
// //                     const _AboutHeader(),
// //                     const SizedBox(height: 28),
// //                     _VideoCard(
// //                       title: 'New SmartPuck App V2',
// //                       description:
// //                           'Learn how to run your SmartPuck App. This video will guide you through the app controls to operate and set up your SmartPuck.',
// //                       player: player,
// //                     ),
// //                     const SizedBox(height: 24),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //           ),
// //         );
// //       },
// //     );
// //   }
// // }

// // class _AboutHeader extends StatelessWidget {
// //   const _AboutHeader();

// //   @override
// //   Widget build(BuildContext context) {
// //     return const Text(
// //       'About',
// //       style: TextStyle(
// //         fontFamily: 'cy_grotesk',
// //         fontSize: 25,
// //         fontWeight: FontWeight.w400,
// //         color: AppColors.textPrimary,
// //       ),
// //     );
// //   }
// // }

// // class _VideoCard extends StatelessWidget {
// //   const _VideoCard({
// //     required this.title,
// //     required this.description,
// //     required this.player,
// //   });

// //   final String title;
// //   final String description;
// //   final Widget player;

// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       decoration: BoxDecoration(
// //         color: AppColors.segmentContainer,
// //         borderRadius: BorderRadius.circular(28),
// //         border: Border.all(color: Colors.white.withOpacity(0.06)),
// //       ),
// //       padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Text(
// //             title,
// //             style: const TextStyle(
// //               fontSize: 16,
// //               fontWeight: FontWeight.w500,
// //               color: AppColors.textPrimary,
// //             ),
// //           ),
// //           const SizedBox(height: 8),
// //           Text(
// //             description,
// //             style: const TextStyle(
// //               fontSize: 12,
// //               height: 1.4,
// //               fontWeight: FontWeight.w400,
// //               color: AppColors.textMuted,
// //             ),
// //           ),
// //           const SizedBox(height: 16),
// //           ClipRRect(
// //             borderRadius: BorderRadius.circular(22),
// //             child: AspectRatio(
// //               aspectRatio: 16 / 9,
// //               child: player,
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:youtube_player_flutter/youtube_player_flutter.dart';
// import '../theme/app_colors.dart';
// import '../components/components.dart';

// /// About screen showing a help / tutorial video.
// ///
// /// The card shows a static thumbnail with a play button. Tapping it opens
// /// a dedicated fullscreen page for the video instead of relying on the
// /// player package's built-in fullscreen mode, which forces a landscape
// /// 16:9 frame — wrong for a portrait screen recording.
// class AboutScreen extends StatelessWidget {
//   const AboutScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: CoyoteBackground(
//         child: SafeArea(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.symmetric(horizontal: 24),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const SizedBox(height: 24),
//                 const _AboutHeader(),
//                 const SizedBox(height: 28),
//                 _VideoCard(
//                   title: 'New SmartPuck App V2',
//                   description:
//                       'Learn how to run your SmartPuck App. This video will guide you through the app controls to operate and set up your SmartPuck.',
//                   videoId: 'ywDT-lFnApQ',
//                   thumbnailAsset: 'assets/images/about1.svg',
//                 ),
//                 const SizedBox(height: 24),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _AboutHeader extends StatelessWidget {
//   const _AboutHeader();

//   @override
//   Widget build(BuildContext context) {
//     return const Text(
//       'About',
//       style: TextStyle(
//         fontFamily: 'cy_grotesk',
//         fontSize: 25,
//         fontWeight: FontWeight.w400,
//         color: AppColors.textPrimary,
//       ),
//     );
//   }
// }

// class _VideoCard extends StatelessWidget {
//   const _VideoCard({
//     required this.title,
//     required this.description,
//     required this.videoId,
//     required this.thumbnailAsset,
//   });

//   final String title;
//   final String description;
//   final String videoId;
//   final String thumbnailAsset;

//   void _openFullScreenPlayer(BuildContext context) {
//     Navigator.of(context).push(
//       MaterialPageRoute(
//         fullscreenDialog: true,
//         builder: (_) => _FullScreenVideoPage(videoId: videoId),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: AppColors.segmentContainer,
//         borderRadius: BorderRadius.circular(28),
//         border: Border.all(color: Colors.white.withOpacity(0.06)),
//       ),
//       padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: const TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w500,
//               color: AppColors.textPrimary,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             description,
//             style: const TextStyle(
//               fontSize: 12,
//               height: 1.4,
//               fontWeight: FontWeight.w400,
//               color: AppColors.textMuted,
//             ),
//           ),
//           const SizedBox(height: 16),
//           ClipRRect(
//             borderRadius: BorderRadius.circular(22),
//             child: AspectRatio(
//               aspectRatio: 16 / 9,
//               child: GestureDetector(
//                 onTap: () => _openFullScreenPlayer(context),
//                 child: Stack(
//                   fit: StackFit.expand,
//                   children: [
//                     ColoredBox(
//                       color: Colors.black,
//                       child: SvgPicture.asset(
//                         thumbnailAsset,
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                     DecoratedBox(
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           begin: Alignment.topCenter,
//                           end: Alignment.bottomCenter,
//                           colors: [
//                             Colors.black.withOpacity(0.05),
//                             Colors.black.withOpacity(0.35),
//                           ],
//                         ),
//                       ),
//                     ),
//                     Center(
//                       child: Container(
//                         width: 64,
//                         height: 64,
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           color: Colors.white.withOpacity(0.85),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.3),
//                               blurRadius: 10,
//                               offset: const Offset(0, 4),
//                             ),
//                           ],
//                         ),
//                         child: const Icon(
//                           Icons.play_arrow_rounded,
//                           size: 36,
//                           color: AppColors.primary,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// /// Dedicated fullscreen page for the video. Sized to the device's own
// /// (portrait) screen ratio instead of the player's default 16:9, and
// /// exited via a manual close button rather than the package's built-in
// /// fullscreen toggle — avoids the landscape lock and flicker that come
// /// with the package's automatic fullscreen handling.
// class _FullScreenVideoPage extends StatefulWidget {
//   const _FullScreenVideoPage({required this.videoId});

//   final String videoId;

//   @override
//   State<_FullScreenVideoPage> createState() => _FullScreenVideoPageState();
// }

// class _FullScreenVideoPageState extends State<_FullScreenVideoPage> {
//   late final YoutubePlayerController _controller;

//   @override
//   void initState() {
//     super.initState();
//     _controller = YoutubePlayerController(
//       initialVideoId: widget.videoId,
//       flags: const YoutubePlayerFlags(
//         autoPlay: true,
//         mute: false,
//         // hideFullScreenButton: true,
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenSize = MediaQuery.of(context).size;

//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: SafeArea(
//         child: Stack(
//           children: [
//             Center(
//               child: YoutubePlayer(
//                 controller: _controller,
//                 showVideoProgressIndicator: true,
//                 progressIndicatorColor: Colors.red,
//                 aspectRatio: screenSize.width / screenSize.height,
//               ),
//             ),
//             Positioned(
//               top: 8,
//               right: 8,
//               child: IconButton(
//                 icon: const Icon(Icons.close, color: Colors.white, size: 28),
//                 onPressed: () => Navigator.of(context).pop(),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../theme/app_colors.dart';
import '../components/components.dart';

/// About screen showing a help / tutorial video.
///
/// The card shows a static thumbnail with a play button. Tapping it opens
/// a dedicated fullscreen page for the video instead of relying on the
/// player package's built-in fullscreen mode, which forces a landscape
/// 16:9 frame — wrong for a portrait screen recording.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CoyoteBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                const _AboutHeader(),
                const SizedBox(height: 28),
                _VideoCard(
                  title: 'New SmartPuck App V2',
                  description:
                      'Learn how to run your SmartPuck App. This video will guide you through the app controls to operate and set up your SmartPuck.',
                  videoId: 'ywDT-lFnApQ',
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AboutHeader extends StatelessWidget {
  const _AboutHeader();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'About',
      style: TextStyle(
        fontFamily: 'cy_grotesk',
        fontSize: 25,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _VideoCard extends StatelessWidget {
  const _VideoCard({
    required this.title,
    required this.description,
    required this.videoId,
  });

  final String title;
  final String description;
  final String videoId;

  void _openFullScreenPlayer(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _FullScreenVideoPage(videoId: videoId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.segmentContainer,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 12,
              height: 1.4,
              fontWeight: FontWeight.w400,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: GestureDetector(
                onTap: () => _openFullScreenPlayer(context),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ColoredBox(
                      color: Colors.black,
                      child: Image.network(
                        'https://img.youtube.com/vi/$videoId/hqdefault.jpg',
                        fit: BoxFit.cover,
                        loadingBuilder: (_, child, progress) {
                          if (progress == null) return child;
                          return const ColoredBox(color: Colors.black);
                        },
                        errorBuilder: (_, __, ___) => const ColoredBox(
                          color: Colors.black,
                        ),
                      ),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.05),
                            Colors.black.withOpacity(0.35),
                          ],
                        ),
                      ),
                    ),
                    Center(
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.85),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          size: 36,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dedicated fullscreen page for the video. Sized to the device's own
/// (portrait) screen ratio instead of the player's default 16:9, and
/// exited via a manual close button rather than the package's built-in
/// fullscreen toggle — avoids the landscape lock and flicker that come
/// with the package's automatic fullscreen handling.
class _FullScreenVideoPage extends StatefulWidget {
  const _FullScreenVideoPage({required this.videoId});

  final String videoId;

  @override
  State<_FullScreenVideoPage> createState() => _FullScreenVideoPageState();
}

class _FullScreenVideoPageState extends State<_FullScreenVideoPage> {
  late final YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        // hideFullScreenButton: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: YoutubePlayer(
                controller: _controller,
                showVideoProgressIndicator: true,
                progressIndicatorColor: Colors.red,
                aspectRatio: screenSize.width / screenSize.height,
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}