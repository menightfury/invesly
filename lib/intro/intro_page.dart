import 'package:invesly/authentication/login_page.dart';
import 'package:invesly/authentication/user_model.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/database/import_backup_page.dart';
import 'package:invesly/main.dart';

import 'package:invesly/common/cubit/app_cubit.dart';
import 'package:invesly/transactions/dashboard/view/dashboard_screen.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> with SingleTickerProviderStateMixin {
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

  Future<void> _handleCompletePressed(BuildContext context) async {
    if (_currentPage.value != _pageData.length - 1) return;

    final settingsState = context.read<AppCubit>().state;
    if (settingsState.currentUser == null) {
      final user = await LoginPage.showModal(context);

      if (!context.mounted || user == null) {
        // User cancelled sign-in or error occurred
        return;
      }

      // Save current user
      context.read<AppCubit>().saveCurrentUser(user);

      if (user == InveslyUser.empty()) {
        // User chose to continue without sign-in
        // Write initial database file from assets
        // await context.read<AuthRepository>().writeDatabaseFile();
      } else {
        // User signed in successfully
        await ImportBackupPage.showModal(context);
      }

      // Load database
      await Bootstrap.instance.api.initializeDatabase();

      if (!context.mounted) return;
      context.read<AppCubit>().completeOnboarding();
      // context.go(AppRouter.initialDeeplink ?? AppRouter.dashboard);
      context.go(const DashboardScreen());
    }
  }

  void _animateToPage(int index) {
    _pageController.animateToPage(index, duration: 300.ms, curve: Curves.easeInOut);
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
                          duration: 600.ms,
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
        return AnimatedScale(scale: pageIndex == _pageData.length - 1 ? 1.0 : 0.0, duration: 200.ms, child: child);
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
