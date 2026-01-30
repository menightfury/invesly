import 'package:invesly/authentication/auth_ui_functions.dart';
import 'package:invesly/authentication/user_model.dart';
import 'package:invesly/common/cubit/app_cubit.dart';
import 'package:invesly/common/presentations/components/google_signin_button.dart';
import 'package:invesly/common/presentations/widgets/section.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/database/backup/restore_drive_backup_page.dart';
import 'package:invesly/dashboard/view/dashboard_page.dart';
import 'package:invesly/settings/currency_selector_page.dart';
import 'package:invesly/common/model/currency.dart';
import 'package:invesly/common/data/currencies.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  late final PageController _pageController;
  late final ValueNotifier<int> _currentPage;

  List<_PageModel> get _pageData => [
    const _PageModel(
      title: 'Welcome',
      description:
          'With Invesly, you can finally achieve the stress free independence. You will have graphs, statistics, tips and so much more.',
      imgSrc: 'assets/images/intro/chart.png',
    ),
    _PageModel(
      title: 'Manage all your accounts',
      description:
          'Your default currency will be used in reports and general charts. You will be able to change currency later at any time in the application settings.',
      imgSrc: 'assets/images/intro/piggybank.png',
      extra: _CurrencySelector(),
    ),
    _PageModel(
      title: 'Safe, protected and reliable',
      description:
          'Your data is truly yours. The information is stored in your device and synced with your Google Drive account (optional).\n\nThis makes this app possible to use it without using internet, while at the same time offers to backup and restore your data even if your device is lost or switched.',
      imgSrc: 'assets/images/intro/locker.png',
      extra: _SigninButtonGroup(),
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
          duration: 240.ms,
          curve: Curves.easeInOut,
          child: child,
        );
      },
      child: IconButton(
        icon: const Icon(Icons.arrow_forward_rounded),
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

class _Page extends StatelessWidget {
  const _Page(this.data, {super.key});

  final _PageModel data;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Spacer(),
        _PageImage(data.imgSrc),
        const Gap(40.0),
        Text(data.title, style: context.textTheme.headlineLarge),
        const Gap(24.0),
        Text(data.description, textAlign: TextAlign.center),
        if (data.extra != null) Padding(padding: EdgeInsetsGeometry.symmetric(vertical: 16.0), child: data.extra),
        Spacer(flex: 2),
      ],
    );
  }
}

class _PageImage extends StatefulWidget {
  const _PageImage(this.imgSrc, {super.key});

  final String imgSrc;

  @override
  State<_PageImage> createState() => __PageImageState();
}

class __PageImageState extends State<_PageImage> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<Offset> _offsetAnimation;

  static const _imageSize = 176.0;

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
    return SlideTransition(
      position: _offsetAnimation,
      child: Stack(
        children: <Widget>[
          Material(
            type: MaterialType.circle,
            color: context.colors.primaryContainer.withAlpha(128),
            child: SizedBox.square(dimension: _imageSize),
          ),
          Image.asset(widget.imgSrc, height: _imageSize, width: _imageSize),
        ],
      ),
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
        return SectionTile(
          icon: CircleAvatar(
            backgroundColor: context.theme.primaryColor,
            foregroundColor: context.theme.colorScheme.onPrimary,
            child: Text(selected.symbol),
          ),
          title: Text('Currency', style: context.textTheme.labelSmall?.copyWith(color: context.colors.secondary)),
          subtitle: Text(selected.name, style: context.textTheme.titleMedium),
          onTap: () => context.push(const CurrencySelectorPage()),
          trailingIcon: Icon(Icons.keyboard_arrow_down_rounded, color: context.colors.onSurfaceVariant),
          shape: RoundedRectangleBorder(
            side: BorderSide(color: context.colors.outlineVariant),
            borderRadius: iCardBorderRadius,
          ),
          tileColor: context.colors.surface,
          padding: const EdgeInsets.all(16.0),
        );
      },
    );
  }
}

class _SigninButtonGroup extends StatelessWidget {
  const _SigninButtonGroup({super.key});

  // Future<void> _onSignInPressed(BuildContext context) async {
  //   final user = await startLoginFlow(context);
  //   if (!context.mounted) return;
  //   _finalizeSetUp(context, user);
  // }

  void _onWithoutSignInPressed(BuildContext context) {
    // _finalizeSetUp(context, InveslyUser.empty());
    _finalizeSetUp(context, null);
  }

  Future<void> _finalizeSetUp(BuildContext context, InveslyUser? user) async {
    context.read<AppCubit>().completeOnboarding();
    // late final bool? restoreStatus;
    if (user.isNullOrEmpty) {
      // User chose to continue without sign-in
      // Write initial database file from assets
      // await context.read<AuthRepository>().writeDatabaseFile();
    } else {
      // User signed in successfully
      // restoreStatus =
      context.go(const RestoreDriveBackupPage());
      return;
    }

    // context.go(AppRouter.initialDeeplink ?? AppRouter.dashboard);
    context.go(const DashboardPage());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 16.0,
      children: <Widget>[
        SizedBox(
          width: double.infinity,
          // child: FilledButton.icon(
          //   onPressed: () => _onSignInPressed(context),
          //   icon: CircleAvatar(radius: 12.0, child: Image.asset('assets/images/google_logo.png')),
          //   label: const Text('Sign in with Google', textAlign: TextAlign.center),
          // ),
          child: GoogleSigninButton(onSigninComplete: (user) => _finalizeSetUp(context, user)),
        ),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => _onWithoutSignInPressed(context),
            child: const Text('Continue without sign in', textAlign: TextAlign.center),
          ),
        ),
      ],
    );
  }
}
