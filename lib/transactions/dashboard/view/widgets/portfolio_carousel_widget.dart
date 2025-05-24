// ignore_for_file: unused_element

import 'package:invesly/common_libs.dart';

import '../../../model/transaction_model.dart';

class _PortfolioCarouselWidget extends StatefulWidget {
  const _PortfolioCarouselWidget({required this.pages, super.key});

  final List<_CaroselPageModel> pages;

  @override
  _PortfolioCarouselWidgetState createState() => _PortfolioCarouselWidgetState();
}

class _PortfolioCarouselWidgetState extends State<_PortfolioCarouselWidget> {
  late final ValueNotifier<int> _currentPage;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentPage = ValueNotifier<int>(0);
    _pageController = PageController(initialPage: 0, viewportFraction: 0.8);
  }

  @override
  void dispose() {
    _currentPage.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(4.0),
          child: AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) {
              double scale = 1.0;
              double itemOffset = 0.0;
              double page = _pageController.initialPage.toDouble();
              final position = _pageController.position;
              if (position.hasPixels && position.hasContentDimensions) {
                page = _pageController.page ?? page;
              }
              itemOffset = page - index;

              final num t = (1 - (itemOffset.abs() * 0.6)).clamp(0.7, 1.0);
              scale = Curves.easeOut.transform(t as double);

              return Transform.scale(scale: scale, child: Opacity(opacity: scale, child: child));
            },
            child: _CarouselPage(pageData: widget.pages[index]),
          ),
        );
      },
      itemCount: widget.pages.length,
      onPageChanged: (value) => _currentPage.value = value,
    );
  }
}

class _CarouselPage extends StatelessWidget {
  const _CarouselPage({super.key, required this.pageData});

  final _CaroselPageModel pageData;

  @override
  Widget build(BuildContext context) {
    final amount = pageData.transactions.fold<double>(0, (v, el) => v + el.totalAmount);

    return Material(
      elevation: 2.0,
      borderRadius: BorderRadius.circular(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Text(
              pageData.title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18.0),
            ),
            const SizedBox(height: 8.0),
            Image.asset(pageData.imgSrc, height: 90.0, fit: BoxFit.cover),
            const SizedBox(height: 8.0),
            Text(
              amount.toCompact(),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.normal, fontSize: 12.0),
            ),
          ],
        ),
      ),
    );
  }
}

@immutable
class _CaroselPageModel {
  const _CaroselPageModel({required this.title, this.transactions = const [], required this.imgSrc});

  final String title;
  final List<InveslyTransaction> transactions;
  final String imgSrc;
}

// Container(
//   width: 180,
//   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
//   decoration: ShapeDecoration(
//     gradient: LinearGradient(
//       begin: Alignment(1.00, 0.04),
//       end: Alignment(0.00, 1.00),
//       colors: [const Color(0xFFA8EDEA), const Color(0xFFFED6E3)],
//     ),
//     shape: RoundedRectangleBorder(
//       borderRadius: BorderRadius.circular(12),
//     ),
//     shadows: [
//       BoxShadow(
//         color: Color(0x26000000),
//         blurRadius: 6,
//         offset: Offset(0, 2),
//         spreadRadius: 2,
//       )BoxShadow(
//         color: Color(0x4C000000),
//         blurRadius: 2,
//         offset: Offset(0, 1),
//         spreadRadius: 0,
//       )
//     ],
//   ),
//   child: Column(
//     mainAxisSize: MainAxisSize.min,
//     mainAxisAlignment: MainAxisAlignment.center,
//     crossAxisAlignment: CrossAxisAlignment.center,
//     spacing: 16,
//     children: [
//       Container(
//         width: double.infinity,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           mainAxisAlignment: MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           spacing: 4,
//           children: [
//             SizedBox(
//               width: 148,
//               child: Text(
//                 'Aditya Birla Sunlife Full Potential Nifty Fifty',
//                 style: TextStyle(
//                   color: Colors.black,
//                   fontSize: 14,
//                   fontFamily: 'Fredoka',
//                   fontWeight: FontWeight.w400,
//                 ),
//               ),
//             ),
//             Row(
//               mainAxisSize: MainAxisSize.min,
//               mainAxisAlignment: MainAxisAlignment.start,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               spacing: 6,
//               children: [
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                   decoration: ShapeDecoration(
//                     color: const Color(0xFFF1B50D),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(24),
//                     ),
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       Text(
//                         'Regular',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 10,
//                           fontFamily: 'Fredoka',
//                           fontWeight: FontWeight.w400,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                   decoration: ShapeDecoration(
//                     color: const Color(0xFF109DA3),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(24),
//                     ),
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       Text(
//                         'LargeCap',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 10,
//                           fontFamily: 'Fredoka',
//                           fontWeight: FontWeight.w400,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//       SizedBox(
//         width: 148,
//         child: Text(
//           'Rs. 1,344',
//           textAlign: TextAlign.right,
//           style: TextStyle(
//             color: Colors.black,
//             fontSize: 24,
//             fontFamily: 'Fredoka',
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ),
//       Container(
//         width: double.infinity,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           mainAxisAlignment: MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           spacing: 12,
//           children: [
//             Container(
//               width: double.infinity,
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Container(
//                     width: double.infinity,
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       spacing: 49,
//                       children: [
//                         Text(
//                           'Mutual fund',
//                           style: TextStyle(
//                             color: Colors.black,
//                             fontSize: 10,
//                             fontFamily: 'Fredoka',
//                             fontWeight: FontWeight.w400,
//                           ),
//                         ),
//                         Text(
//                           '35%',
//                           style: TextStyle(
//                             color: Colors.black,
//                             fontSize: 10,
//                             fontFamily: 'Fredoka',
//                             fontWeight: FontWeight.w400,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Container(
//                     width: 148,
//                     height: 4,
//                     decoration: ShapeDecoration(
//                       color: const Color(0x33109DA3),
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                     ),
//                   ),
//                   Container(
//                     width: 57.39,
//                     height: 4,
//                     decoration: ShapeDecoration(
//                       color: const Color(0xFF109DA3),
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Container(
//               width: double.infinity,
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Container(
//                     width: double.infinity,
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       spacing: 49,
//                       children: [
//                         Text(
//                           'Total',
//                           style: TextStyle(
//                             color: Colors.black,
//                             fontSize: 10,
//                             fontFamily: 'Fredoka',
//                             fontWeight: FontWeight.w400,
//                           ),
//                         ),
//                         Text(
//                           '5%',
//                           style: TextStyle(
//                             color: Colors.black,
//                             fontSize: 10,
//                             fontFamily: 'Fredoka',
//                             fontWeight: FontWeight.w400,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Container(
//                     width: 148,
//                     height: 4,
//                     decoration: ShapeDecoration(
//                       color: const Color(0x33109DA3),
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                     ),
//                   ),
//                   Container(
//                     width: 57.39,
//                     height: 4,
//                     decoration: ShapeDecoration(
//                       color: const Color(0xFF109DA3),
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     ],
//   ),
// )
