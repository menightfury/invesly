import 'package:invesly/authentication/auth_ui_functions.dart';
import 'package:invesly/authentication/user_model.dart';
import 'package:invesly/common/cubit/app_cubit.dart';
import 'package:invesly/common/presentations/animations/animated_expanded.dart';
import 'package:invesly/common/presentations/animations/fade_in.dart';
import 'package:invesly/common/presentations/widgets/section.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/database/import_backup_page.dart';
import 'package:invesly/dashboard/view/dashboard_screen.dart';
import 'package:invesly/settings/currency_selector_screen.dart';
import 'package:invesly/common/model/currency.dart';
import 'package:invesly/common/data/currencies.dart';

// const _kPaddingTop = 48.0;

// const _kSpaceFromHeaderToImage = 56.0;

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  late final PageController _pageController;
  late final ValueNotifier<int> _currentPage;

  // final $strings = $localeService.strings;

  List<_PageModel> get _pageData => [
    const _PageModel(
      // title: $strings.introWelcomeTitle,
      title: 'Welcome',
      // description: $strings.introWelcomeDescription,
      description:
          'With Invesly, you can finally achieve the stress free independence. You will have graphs, statistics, tips and so much',
      imgSrc: 'assets/images/intro/chart.png',
    ),
    _PageModel(
      // title: $strings.introMoneyTitle,
      title: 'Manage all your accounts',
      // description: $strings.introMoneyDescription,
      description:
          'Your default currency will be used in reports and general charts. You will be able to change currency later at any time in the application settings',
      imgSrc: 'assets/images/intro/piggybank.png',
      extra: _CurrencySelector(),
    ),
    _PageModel(
      // title: $strings.introPayLaterTitle,
      title: 'Safe, protected and reliable',
      // description: $strings.introPayLaterDescription,
      description:
          'Your data is truly yours. The information is stored in your device and synced with your Google Drive account (optional).\n\nThis makes this app possible to use it without using internet, while at the same time offers to backup and restore your data even if your device is lost or switched. ',
      imgSrc: 'assets/images/intro/locker.png',
      extra: SizedBox(
        width: double.infinity,
        child: FilledButton.tonalIcon(
          onPressed: () => _onWithoutSignInPressed(context),
          label: const Icon(Icons.arrow_forward_rounded),
          icon: const Text('Continue without sign in', textAlign: TextAlign.center),
        ),
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _currentPage = ValueNotifier<int>(0);
    _pageController = PageController();
  }

  @override
  void dispose() {
    _currentPage.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildNextBtn(BuildContext context) {
    final theme = Theme.of(context);

    return ValueListenableBuilder<int>(
      valueListenable: _currentPage,
      builder: (_, pageIndex, child) {
        return AnimatedScale(
          scale: pageIndex == _pageData.length - 1 ? 0.0 : 1.0,
          // alignment: Alignment.centerRight,
          duration: 240.ms,
          curve: Curves.easeInOut,
          child: child,
        );
      },
      child: FilledButton.icon(
        icon: const Text('Next', textAlign: TextAlign.center),
        label: const Icon(Icons.arrow_forward_rounded),
        onPressed: () {
          if (_currentPage.value < _pageData.length - 1) {
            _animateToPage(_currentPage.value + 1);
          }
        },
        style: IconButton.styleFrom(
          foregroundColor: theme.colorScheme.onPrimary,
          backgroundColor: theme.colorScheme.primary,
        ),
      ),
    );
  }

  void _animateToPage(int index) {
    _pageController.animateToPage(index, duration: 300.ms, curve: Curves.easeInOut);
  }

  Future<void> _onSignInPressed(BuildContext context) async {
    final user = await startLoginFlow(context);
    if (!context.mounted) return;
    _finalizeSetUp(context, user);
  }

  void _onWithoutSignInPressed(BuildContext context) {
    // _finalizeSetUp(context, InveslyUser.empty());
    _finalizeSetUp(context, null);
  }

  Future<void> _finalizeSetUp(BuildContext context, InveslyUser? user) async {
    // late final bool? restoreStatus;
    if (user.isNullOrEmpty) {
      // User chose to continue without sign-in
      // Write initial database file from assets
      // await context.read<AuthRepository>().writeDatabaseFile();
    } else {
      // User signed in successfully
      // restoreStatus =
      await DriveImportBackupPage.showModal(context);
    }

    if (!context.mounted) {
      return;
    }
    context.read<AppCubit>().completeOnboarding();
    // context.go(AppRouter.initialDeeplink ?? AppRouter.dashboard);
    context.go(const DashboardScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          alignment: Alignment.topCenter,
          children: <Widget>[
            PageView.builder(
              controller: _pageController,
              itemBuilder: (_, index) => Padding(padding: const EdgeInsets.all(16.0), child: _Page(_pageData[index])),
              itemCount: _pageData.length,
              onPageChanged: (value) => _currentPage.value = value,
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 32.0),
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
                        expansionFactor: 3.0,
                        activeDotColor: context.colors.secondary,
                      ),
                      onDotClicked: (index) => _animateToPage(index),
                    ),

                    // ~ Next button
                    _buildNextBtn(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

@immutable
class _PageModel {
  const _PageModel({required this.title, required this.description, required this.imgSrc, this.extra});

  final String title;
  final String description;
  final String imgSrc;
  final Widget? extra;
}

class _Page extends StatefulWidget {
  const _Page(this.data);

  final _PageModel data;

  @override
  State<_Page> createState() => _PageState();
}

class _PageState extends State<_Page> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<Offset> _offsetAnimation;

  static const _kImageSize = 176.0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: 3.seconds)..repeat(reverse: true);
    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.0, 0.1),
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      // mainAxisSize: MainAxisSize.min,
      // crossAxisAlignment: CrossAxisAlignment.start,
      // spacing: _kSpaceFromHeaderToImage,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        // ~ Image
        SlideTransition(
          position: _offsetAnimation,
          child: Stack(
            children: <Widget>[
              Material(
                type: MaterialType.circle,
                color: context.colors.primaryContainer.withAlpha(128),
                child: SizedBox.square(dimension: _kImageSize),
              ),
              Image.asset(widget.data.imgSrc, height: _kImageSize, width: _kImageSize),
            ],
          ),
        ),
        const Gap(40.0),
        Text(widget.data.title, style: context.textTheme.headlineLarge),
        const Gap(24.0),
        Text(widget.data.description, textAlign: TextAlign.center),
        if (widget.data.extra != null)
          Padding(padding: EdgeInsetsGeometry.symmetric(vertical: 16.0), child: widget.data.extra),
        const Gap(48.0),
      ],
    );
  }
}

class _CurrencySelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocSelector<AppCubit, AppState, Currency?>(
      selector: (state) => state.currency,
      builder: (context, currency) {
        final selected = currency ?? Currencies.defaultCurrency;
        return InkWell(
          onTap: () => context.push(const CurrencySelectorScreen()),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: context.colors.outlineVariant),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: context.colors.primaryContainer, shape: BoxShape.circle),
                  child: Text(
                    selected.symbol,
                    style: TextStyle(fontWeight: FontWeight.bold, color: context.colors.onPrimaryContainer),
                  ),
                ),
                const Gap(16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Currency', style: context.textTheme.labelSmall?.copyWith(color: context.colors.secondary)),
                      Text(selected.name, style: context.textTheme.titleMedium),
                    ],
                  ),
                ),
                Icon(Icons.keyboard_arrow_down_rounded, color: context.colors.onSurfaceVariant),
              ],
            ),
          ),
        );
      },
    );
  }
}
