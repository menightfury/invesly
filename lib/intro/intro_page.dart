import 'package:invesly/authentication/login_page.dart';
import 'package:invesly/authentication/user_model.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/database/import_backup_page.dart';
import 'package:invesly/main.dart';

import 'package:invesly/common/cubit/app_cubit.dart';
import 'package:invesly/transactions/dashboard/view/dashboard_screen.dart';

const _kPaddingTop = 56.0;
const _kImageSize = 156.0;

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
        description:
            'With Invesly, you can finally achieve the stress free independence. You will have graphs, statistics, tips and so much',
        imgSrc: 'assets/images/intro/chart.png',
      ),
      const _PageModel(
        // title: $strings.introMoneyTitle,
        title: 'Manage all your accounts',
        // description: $strings.introMoneyDescription,
        description:
            'Your default currency will be used in reports and general charts. You will be able to change currency later at any time in the application settings',
        imgSrc: 'assets/images/intro/piggybank.png',
        content: ListTile(title: Text('Select your currency'), subtitle: Text('Indian rupee')),
      ),
      _PageModel(
        // title: $strings.introPayLaterTitle,
        title: 'Safe, protected and reliable',
        // description: $strings.introPayLaterDescription,
        description:
            'Your data is truly yours. The information is stored in your device and synced with your Google Drive account (optional).\nThis makes this app possible to use it without using internet, while at the same time offers to backup and restore your data even if your device is lost or switched. ',
        imgSrc: 'assets/images/intro/locker.png',
        content: ElevatedButton(onPressed: () {}, child: Text('Sign in with Google')),
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
          alignment: Alignment.topCenter,
          children: <Widget>[
            // ~ Image
            Padding(
              padding: const EdgeInsets.only(top: _kPaddingTop + 48.0),
              child: SlideTransition(
                position: _offsetAnimation,
                child: Stack(
                  children: <Widget>[
                    Material(
                      type: MaterialType.circle,
                      color: context.colors.primaryContainer,
                      child: SizedBox.square(dimension: _kImageSize),
                    ),
                    ValueListenableBuilder<int>(
                      valueListenable: _currentPage,
                      builder: (_, value, _) {
                        return AnimatedSwitcher(
                          duration: 600.ms,
                          child: Image.asset(
                            _pageData[value].imgSrc,
                            key: ValueKey(value),
                            height: _kImageSize,
                            width: _kImageSize,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            PageView.builder(
              controller: _pageController,
              itemBuilder: (_, index) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, _kPaddingTop, 16.0, 72.0),
                  child: _Page(_pageData[index]),
                );
              },
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

                    // // ~ Finish button
                    // _buildFinishBtn(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      persistentFooterButtons: <Widget>[
        SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ElevatedButton.icon(
              onPressed: () => _handleCompletePressed(context),
              label: const Text('Next'),
              icon: const Icon(Icons.keyboard_arrow_right_rounded),
            ),
          ),
        ),
      ],
      persistentFooterAlignment: AlignmentDirectional.center,
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
  const _PageModel({required this.title, this.description, required this.imgSrc, this.content});

  final String title;
  final String? description;
  final String imgSrc;
  final Widget? content;
}

class _Page extends StatelessWidget {
  const _Page(this.data);

  final _PageModel data;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // width: 256.0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 24.0,
        children: <Widget>[
          Text(data.title, style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w600)),
          const SizedBox(height: _kImageSize), // space for image
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                spacing: 16.0,
                children: <Widget>[
                  if (data.description != null) Text(data.description!, style: context.textTheme.bodySmall),
                  ?data.content,
                ],
              ),
            ),
          ),
          // const SizedBox(height: 112.0), // space for indicators
        ],
      ),
    );
  }
}
