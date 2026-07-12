import 'package:invesly/accounts/edit_account/cubit/edit_account_cubit.dart';
import 'package:invesly/accounts/model/account_model.dart';
import 'package:invesly/accounts/model/account_repository.dart';
import 'package:invesly/common/extensions/widget_extension.dart';
import 'package:invesly/common/presentations/animations/shake.dart';
import 'package:invesly/common/presentations/widgets/popups.dart';
import 'package:invesly/common/utils/keyboard.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/dashboard/view/dashboard_page.dart';

class EditAccountPage extends StatelessWidget {
  const EditAccountPage({super.key, this.initialAccount});

  final InveslyAccount? initialAccount;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EditAccountCubit(repository: AccountRepository.instance, initial: initialAccount),
      child: const _EditAccountPageContent(),
    );
  }
}

class _EditAccountPageContent extends StatefulWidget {
  const _EditAccountPageContent({super.key});

  @override
  State<_EditAccountPageContent> createState() => _EditAccountPageContentState();
}

class _EditAccountPageContentState extends State<_EditAccountPageContent> {
  // final _nameShakeKey = GlobalKey<ShakeState>();
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<EditAccountCubit>();
    _nameController = TextEditingController(text: cubit.state.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    $logger.i('Rebuilding edit account screen');
    final cubit = context.read<EditAccountCubit>();

    return BlocListener<EditAccountCubit, EditAccountState>(
      listenWhen: (prev, curr) => prev.status != curr.status && curr.isFailureOrSuccess,
      listener: (context, state) {
        late final SnackBar message;

        if (state.status == EditAccountStatus.success) {
          message = const SnackBar(content: Text('Account saved successfully'), backgroundColor: Colors.teal);
          context.canPop ? Navigator.pop(context) : context.go(const DashboardPage());
        } else if (state.status == EditAccountStatus.failure) {
          message = const SnackBar(content: Text('Sorry! some error occurred'), backgroundColor: Colors.redAccent);
        }
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(message);
      },
      child: PopScope(
        canPop: false, // prevents default
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop) return;

          if (cubit.state.isEdited) {
            final shouldPop = await showDiscardChangesDialog(context) ?? false;
            if (shouldPop && context.mounted) Navigator.pop(context);
          } else {
            if (context.mounted) Navigator.pop(context);
          }
        },
        child: Scaffold(
          body: SafeArea(
            child: CustomScrollView(
              slivers: <Widget>[
                SliverAppBar(
                  //   title: ScrollBasedSliverAppBarContentBuilder(
                  //     // Not working properly, fix this
                  //     builder: (context, opacity) {
                  //       return Text(
                  //         cubit.state.isNewAccount ? 'Add account' : 'Edit account',
                  //         style: TextStyle(color: Colors.black.withOpacity(opacity)),
                  //       );
                  //     },
                  //   ),
                  snap: true,
                  floating: true,
                ),
                SliverList(
                  delegate: SliverChildListDelegate.fixed(<Widget>[
                    // ~ Title
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('Welcome,', style: context.textTheme.headlineSmall),
                          BlocSelector<EditAccountCubit, EditAccountState, String?>(
                            selector: (state) => state.name,
                            builder: (context, name) {
                              return Text(
                                name == null || name.trim().isEmpty ? 'Investor' : name,
                                style: context.textTheme.headlineMedium,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const Gap(12.0),

                    // ~ Form
                    Column(
                      spacing: 32.0,
                      children: <Widget>[
                        // ~~~ Avatar picker ~~~
                        _AvatarPickerWidget(
                          avatars: InveslyAccountAvatar.values.map((e) => e.imgSrc).toList(),
                          onChanged: cubit.updateAvatar,
                          initialValue: cubit.state.avatarIndex,
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 12.0,
                            children: <Widget>[
                              // ~ Name
                              BlocBuilder<EditAccountCubit, EditAccountState>(
                                buildWhen: (prev, curr) {
                                  return prev.nameError != curr.nameError ||
                                      (prev.status != curr.status && curr.isError);
                                },
                                builder: (context, state) {
                                  $logger.w('Name field re-builds');
                                  final isError = state.nameError != null;
                                  return Shake(
                                    shake: isError,
                                    child: TextField(
                                      decoration: InputDecoration(
                                        hintText: 'e.g. John Doe',
                                        helperText: cubit.state.isNewAccount ? 'Title can\'t be changed later' : null,
                                        errorText: state.nameError,
                                      ),
                                      controller: _nameController,
                                      onChanged: cubit.updateName,
                                      enabled: cubit.state.isNewAccount,
                                      onTapOutside: (_) => minimizeKeyboard(),
                                    ),
                                  );
                                },
                              ).withLabel('Title'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ]),
                ),
              ],
            ),
          ),

          persistentFooterButtons: <Widget>[
            BlocSelector<EditAccountCubit, EditAccountState, bool>(
              selector: (state) => state.isLoadingOrSuccess,
              builder: (context, isLoadingOrSuccess) {
                return SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ElevatedButton.icon(
                      onPressed: isLoadingOrSuccess ? null : () => _handleSavePressed(context),
                      label: isLoadingOrSuccess ? const Text('Saving account...') : const Text('Save account'),
                      icon: isLoadingOrSuccess
                          ? CircularProgressIndicator(
                              strokeWidth: 2.0,
                              // color: Colors.white,
                              constraints: BoxConstraints.tightForFinite(width: 16.0, height: 16.0),
                            )
                          : Icon(Icons.save_alt_rounded),
                    ),
                  ),
                );
              },
            ),
          ],
          persistentFooterAlignment: AlignmentDirectional.center,
        ),
      ),
    );
  }

  // ~ Save account
  Future<void> _handleSavePressed(BuildContext context) async {
    context.read<EditAccountCubit>().save();
  }
}

class _AvatarPickerWidget extends FormField<int> {
  _AvatarPickerWidget({
    super.key,
    required List<String> avatars,
    super.initialValue,
    ValueChanged<int>? onChanged,
    super.validator,
    super.onSaved,
  }) : super(
         builder: (FormFieldState<int> field) {
           final __AvatarPickerWidgetState state = field as __AvatarPickerWidgetState;
           void onChangedHandler(int idx) {
             onChanged?.call(idx);
           }

           return SizedBox(
             height: 150.0,
             child: PageView.builder(
               controller: state.controller,
               itemBuilder: (context, index) {
                 return AnimatedBuilder(
                   animation: state.controller,
                   builder: (context, _) {
                     double scale = 1.0;
                     double itemOffset = 0.0;
                     double page = state.controller.initialPage.toDouble();
                     final position = state.controller.position;
                     if (position.hasPixels && position.hasContentDimensions) {
                       page = state.controller.page ?? page;
                     }
                     itemOffset = page - index;

                     final num t = (1 - (itemOffset.abs() * 0.6)).clamp(0.3, 1.0);
                     scale = Curves.easeOut.transform(t as double);

                     return Transform.scale(
                       scale: scale,
                       child: Image.asset(
                         avatars[index],
                         color: Color.fromRGBO(255, 255, 255, scale),
                         colorBlendMode: BlendMode.modulate,
                       ),
                     );
                   },
                 );
               },
               itemCount: avatars.length,
               onPageChanged: onChangedHandler,
             ),
           );
         },
       );

  @override
  FormFieldState<int> createState() => __AvatarPickerWidgetState();
}

class __AvatarPickerWidgetState extends FormFieldState<int> {
  late final PageController _avatarController;

  PageController get controller => _avatarController;

  @override
  void initState() {
    _avatarController = PageController(initialPage: widget.initialValue ?? 0, viewportFraction: 0.35);
    super.initState();
  }

  @override
  void dispose() {
    _avatarController.dispose();
    super.dispose();
  }
}

class ScrollBasedSliverAppBarContentBuilder extends StatefulWidget {
  const ScrollBasedSliverAppBarContentBuilder({super.key, required this.builder});

  final Widget Function(BuildContext context, double opacity) builder;

  @override
  State<ScrollBasedSliverAppBarContentBuilder> createState() => _ScrollBasedSliverAppBarContentBuilderState();
}

class _ScrollBasedSliverAppBarContentBuilderState extends State<ScrollBasedSliverAppBarContentBuilder> {
  ScrollPosition? _position;
  late final FlexibleSpaceBarSettings settings;
  late final ValueNotifier<double> _opacityNotifier;

  @override
  void initState() {
    super.initState();
    _opacityNotifier = ValueNotifier(0);
    settings = context.getInheritedWidgetOfExactType<FlexibleSpaceBarSettings>()!;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_position != null) {
      _position!.removeListener(_positionListener);
    }
    _position = Scrollable.maybeOf(context)?.position;
    if (_position != null) {
      _position!.addListener(_positionListener);
    }
  }

  @override
  void dispose() {
    if (_position != null) {
      _position!.removeListener(_positionListener);
    }
    super.dispose();
  }

  void _positionListener() {
    _opacityNotifier.value = ((_position!.extentBefore - settings.minExtent) / 100).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: _opacityNotifier,
      builder: (context, value, _) {
        return widget.builder(context, value);
      },
    );
  }
}
