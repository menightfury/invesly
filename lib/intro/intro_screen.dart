// ignore_for_file: avoid_print

import 'package:invesly/common_libs.dart';

import 'package:invesly/settings/cubit/settings_cubit.dart';
import 'package:invesly/transactions/dashboard/view/dashboard_screen.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> with SingleTickerProviderStateMixin {
  List<_PageModel> _pageData = [];

  late final PageController _pageController;
  late final ValueNotifier<int> _currentPage;

  late final AnimationController _animController;
  late final Animation<Offset> _offsetAnimation;
  // final $strings = $localeService.strings;

  @override
  void initState() {
    super.initState();
    _currentPage = ValueNotifier<int>(0);
    _pageController = PageController();

    _animController = AnimationController(vsync: this, duration: 3.seconds)..repeat(reverse: true);
    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.0, 0.1),
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeInOut));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pageData = [
      const _PageModel(
        // title: $strings.introWelcomeTitle,
        title: 'Welcome',
        // description: $strings.introWelcomeDescription,
        description: 'Some description here',
        imgSrc: 'assets/images/intro/piggybank.png',
      ),
      const _PageModel(
        // title: $strings.introMoneyTitle,
        title: 'Easy money management',
        // description: $strings.introMoneyDescription,
        description: 'Manage your money with ease',
        imgSrc: 'assets/images/intro/locker.png',
      ),
      const _PageModel(
        // title: $strings.introPayLaterTitle,
        title: 'Pay later for the things you love',
        // description: $strings.introPayLaterDescription,
        description: 'Pay anytime you want',
        imgSrc: 'assets/images/intro/trophy.png',
      ),
    ];
  }

  @override
  void dispose() {
    _currentPage.dispose();
    _pageController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _handleCompletePressed(BuildContext context) {
    if (_currentPage.value != _pageData.length - 1) return;

    context.read<SettingsCubit>().completeOnboarding();
    context.go(const DashboardScreen()); // TODO: Make a cubit for this
  }

  void _animateToPage(int index) {
    _pageController.animateToPage(index, duration: EMTimes.fast, curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: <Widget>[
          // ~ Image
          Align(
            alignment: Alignment.topCenter,
            child: Column(
              children: <Widget>[
                SizedBox(height: MediaQuery.viewPaddingOf(context).top + 56.0),
                SlideTransition(
                  position: _offsetAnimation,
                  child: ValueListenableBuilder<int>(
                    valueListenable: _currentPage,
                    builder: (_, value, __) {
                      return AnimatedSwitcher(
                        duration: EMTimes.med,
                        child: Image.asset(_pageData[value].imgSrc, key: ValueKey(value), width: 320.0),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          PageView.builder(
            controller: _pageController,
            itemBuilder: (context, index) => _Page(_pageData[index]),
            itemCount: _pageData.length,
            onPageChanged: (value) => _currentPage.value = value,
          ),

          // ~ Bottom indicator and button
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  // ~ Page indicator
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _pageData.length,
                    effect: ExpandingDotsEffect(
                      dotWidth: 8.0,
                      dotHeight: 8.0,
                      expansionFactor: 2.0,
                      activeDotColor: theme.colorScheme.secondary,
                    ),
                    onDotClicked: (index) => _animateToPage(index),
                  ),

                  // ~ Finish button
                  _buildFinishBtn(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinishBtn(BuildContext context) {
    final theme = Theme.of(context);

    return ValueListenableBuilder<int>(
      valueListenable: _currentPage,
      builder: (_, pageIndex, child) {
        return AnimatedScale(
          scale: pageIndex == _pageData.length - 1 ? 1.0 : 0.0,
          duration: EMTimes.pageTransition,
          child: child,
        );
      },
      child: IconButton(
        icon: const Icon(Icons.arrow_forward_rounded),
        onPressed: () => _handleCompletePressed(context),
        style: IconButton.styleFrom(
          foregroundColor: theme.colorScheme.onPrimary,
          backgroundColor: theme.colorScheme.primary,
        ),
        padding: const EdgeInsets.all(16.0),
      ),
    );
  }
}

@immutable
class _PageModel {
  const _PageModel({required this.title, this.description, required this.imgSrc});

  final String title;
  final String? description;
  final String imgSrc;
}

class _Page extends StatelessWidget {
  const _Page(this.data);

  final _PageModel data;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 32.0),
        child: SizedBox(
          width: 256.0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(data.title, style: textTheme.headlineLarge),
              const SizedBox(height: 16.0),
              if (data.description != null) Text(data.description!),
              const SizedBox(height: 112.0),
            ],
          ),
        ),
      ),
    );
  }
}

// class OnboardingPage extends StatefulWidget {
//   const OnboardingPage({super.key});

//   @override
//   State<OnboardingPage> createState() => _OnboardingPageState();
// }

// class _OnboardingPageState extends State<OnboardingPage> {
//   int currentPage = 0;

//   introFinished() {
//     AppDataService.instance
//         .setItem(AppDataKey.introSeen, '1', updateGlobalState: true)
//         .then(
//       (value) {
//         RouteUtils.pushRoute(
//           context,
//           TabsPage(key: tabsPageKey),
//           withReplacement: true,
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final t = Translations.of(context);

//     List items = [
//       {
//         'header': t.intro.sl1_title,
//         'description': t.intro.sl1_descr,
//         'image': 'assets/icons/app_onboarding/first.svg'
//       },
//       {
//         'header': t.intro.sl2_title,
//         'description': t.intro.sl2_descr,
//         'description2': t.intro.sl2_descr2,
//         'image': 'assets/icons/app_onboarding/security.svg'
//       },
//       {
//         'header': t.intro.last_slide_title,
//         'description': t.intro.last_slide_descr,
//         'description2': t.intro.last_slide_descr2,
//         'image': 'assets/icons/app_onboarding/wallet.svg'
//       },
//     ];

//     List<PageViewModel> slides = items
//         .mapIndexed((index, item) => PageViewModel(
//             titleWidget: Padding(
//               padding:
//                   const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
//               child: Text(
//                 item['header'],
//                 style: Theme.of(context).textTheme.headlineLarge,
//                 textAlign: TextAlign.center,
//               ),
//             ),
//             useRowInLandscape: true,
//             bodyWidget: Padding(
//               padding:
//                   const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
//               child: Column(children: [
//                 Text(
//                   item['description'],
//                   style: const TextStyle(
//                       fontSize: 14.0, fontWeight: FontWeight.w300),
//                   textAlign: TextAlign.justify,
//                 ),
//                 if (item['description2'] != null) ...[
//                   const SizedBox(height: 10),
//                   Text(
//                     item['description2'],
//                     style: const TextStyle(
//                         fontSize: 14.0, fontWeight: FontWeight.w300),
//                     textAlign: TextAlign.justify,
//                   ),
//                 ],
//                 if (index == 0) ...[
//                   const SizedBox(height: 40),
//                   StreamBuilder(
//                       stream:
//                           CurrencyService.instance.getUserPreferredCurrency(),
//                       builder: (context, snapshot) {
//                         final userCurrency = snapshot.data;

//                         return ListTile(
//                           tileColor: Theme.of(context)
//                               .colorScheme
//                               .onBackground
//                               .withOpacity(0.04),
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10)),
//                           trailing: Icon(
//                             Icons.arrow_forward_ios_rounded,
//                             size: 14,
//                             color: Theme.of(context)
//                                 .colorScheme
//                                 .onBackground
//                                 .withOpacity(0.45),
//                           ),
//                           leading: Container(
//                             clipBehavior: Clip.hardEdge,
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(100),
//                             ),
//                             child: userCurrency != null
//                                 ? userCurrency.displayFlagIcon(size: 42)
//                                 : const Skeleton(height: 42, width: 42),
//                           ),
//                           title: Text(t.intro.select_your_currency),
//                           subtitle: userCurrency != null
//                               ? Text(userCurrency.name)
//                               : const Skeleton(height: 12, width: 50),
//                           onTap: () {
//                             if (userCurrency == null) return;

//                             showCurrencySelectorModal(
//                                 context,
//                                 CurrencySelectorModal(
//                                     preselectedCurrency: userCurrency,
//                                     onCurrencySelected: (newCurrency) {
//                                       UserSettingService.instance
//                                           .setItem(SettingKey.preferredCurrency,
//                                               newCurrency.code)
//                                           .then((value) => setState(() => {}));
//                                     }));
//                           },
//                         );
//                       }),
//                 ],
//               ]),
//             ),
//             image: SvgPicture.asset(
//               item['image'],
//               fit: BoxFit.fitWidth,
//               width: 240.0,
//               alignment: Alignment.bottomCenter,
//             )))
//         .toList();

//     return Scaffold(
//         appBar: AppBar(
//           backgroundColor: Colors.transparent,
//           elevation: 0,
//           toolbarHeight: 0,
//         ),
//         body: IntroductionScreen(
//           pages: slides,
//           showSkipButton: true,
//           initialPage: currentPage,
//           onChange: (value) {
//             setState(() {
//               currentPage = value;
//             });
//           },
//           skip: Text(
//             t.intro.skip,
//             style: const TextStyle(fontWeight: FontWeight.w300),
//           ),
//           next: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(t.intro.next),
//               const SizedBox(width: 4),
//               const Icon(Icons.arrow_forward)
//             ],
//           ),
//           done: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(t.ui_actions.continue_text),
//               const SizedBox(width: 4),
//               const Icon(Icons.check)
//             ],
//           ),
//           onDone: () => introFinished(),
//           onSkip: () => introFinished(),
//           dotsDecorator: DotsDecorator(
//             size: const Size.square(10.0),
//             activeSize: const Size(20.0, 10.0),
//             activeColor: Theme.of(context).colorScheme.primary,
//             color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
//             spacing: const EdgeInsets.symmetric(horizontal: 3.0),
//             activeShape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(25.0)),
//           ),
//         ));
//   }
// }
