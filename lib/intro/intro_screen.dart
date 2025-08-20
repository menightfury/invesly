// ignore_for_file: avoid_print

import 'package:invesly/authentication/login_screen.dart';
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

    // context.read<SettingsCubit>().completeOnboarding();
    // context.go(const LoginScreen());
    // final accountsState = context.read<AccountsCubit>().state;
    final settingsState = context.read<SettingsCubit>().state;

    // if (accountsState is AccountsLoadedState) {
    //   if (!context.mounted) return;

    //   // If there are no accounts, go to EditAccountScreen
    //   if (accountsState.hasNoAccount) {
    //     context.go(const EditAccountScreen());
    //     return;
    //   }

    //   // If there are accounts but currentAccountId is null, set the first account as current account
    if (settingsState.currentUser == null) {
      // context.read<SettingsCubit>().saveCurrentAccount(accountsState.accounts.first.id);
      context.go(LoginScreen());
      return;
    }
    //   // context.go(AppRouter.initialDeeplink ?? AppRouter.dashboard);
    context.go(const DashboardScreen());
    // } else if (accountsState is AccountsErrorState) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       backgroundColor: context.colors.errorContainer,
    //       content: Text(
    //         'Error loading users: ${accountsState.errorMsg}',
    //         style: TextStyle(color: context.colors.onErrorContainer),
    //       ),
    //     ),
    //   );
    // }
  }

  void _animateToPage(int index) {
    _pageController.animateToPage(index, duration: EMTimes.fast, curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
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
                      builder: (_, value, _) {
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
              itemBuilder: (_, index) => _Page(_pageData[index]),
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
                        activeDotColor: context.colors.secondary,
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
      ),
    );
  }

  Widget _buildFinishBtn(BuildContext context) {
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
        style: IconButton.styleFrom(foregroundColor: context.colors.onPrimary, backgroundColor: context.colors.primary),
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
              Text(data.title, style: context.textTheme.headlineLarge),
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
