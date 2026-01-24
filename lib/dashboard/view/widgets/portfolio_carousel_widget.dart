// ignore_for_file: unused_element

import 'package:invesly/common_libs.dart';

import '../../../transactions/model/transaction_model.dart';

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

              return Transform.scale(
                scale: scale,
                child: Opacity(opacity: scale, child: child),
              );
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
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 18.0),
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
