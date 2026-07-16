import 'package:invesly/accounts/view/edit_account/cubit/edit_account_cubit.dart';
import 'package:invesly/accounts/model/account_model.dart';
import 'package:invesly/accounts/model/account_repository.dart';
import 'package:invesly/common/extensions/widget_extension.dart';
import 'package:invesly/common/presentations/animations/shake.dart';
import 'package:invesly/common/presentations/widgets/color_picker.dart';
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
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _initialBalanceController;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<EditAccountCubit>();
    _nameController = TextEditingController(text: cubit.state.name);
    _descriptionController = TextEditingController(text: cubit.state.description);
    _initialBalanceController = TextEditingController(
      text: cubit.state.initialBalance == null ? '' : cubit.state.initialBalance!.toString(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _initialBalanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    $logger.i('Rebuilding edit account screen');
    final cubit = context.read<EditAccountCubit>();
    final theme = Theme.of(context);
    final selectedColor = Color(cubit.state.colorValue);

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
        canPop: false,
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
                SliverAppBar(snap: true, floating: true),
                SliverList(
                  delegate: SliverChildListDelegate.fixed(<Widget>[
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

                    Column(
                      spacing: 24.0,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 72.0,
                                height: 72.0,
                                decoration: BoxDecoration(color: selectedColor.withAlpha(0x33), shape: BoxShape.circle),
                                alignment: Alignment.center,
                                child: Icon(
                                  InveslyAccountIcon.fromName(cubit.state.iconName).iconData,
                                  size: 32.0,
                                  color: selectedColor,
                                ),
                              ),
                              const Gap(16.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text('Preview', style: context.textTheme.labelLarge),
                                    Text(
                                      cubit.state.name?.trim().isEmpty == true
                                          ? 'Account title'
                                          : cubit.state.name ?? 'Account title',
                                      style: context.textTheme.titleMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 12.0,
                            children: <Widget>[
                              BlocBuilder<EditAccountCubit, EditAccountState>(
                                buildWhen: (prev, curr) {
                                  return prev.nameError != curr.nameError ||
                                      (prev.status != curr.status && curr.isError);
                                },
                                builder: (context, state) {
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

                              TextField(
                                controller: _descriptionController,
                                decoration: const InputDecoration(hintText: 'e.g. Savings for long-term goals'),
                                maxLines: 3,
                                onChanged: cubit.updateDescription,
                                onTapOutside: (_) => minimizeKeyboard(),
                              ).withLabel('Description'),

                              TextField(
                                controller: _initialBalanceController,
                                decoration: const InputDecoration(hintText: '0.0'),
                                keyboardType: TextInputType.number,
                                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                                onChanged: cubit.updateInitialBalance,
                                onTapOutside: (_) => minimizeKeyboard(),
                              ).withLabel('Initial balance'),
                            ],
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 12.0,
                            children: <Widget>[
                              Text('Icon', style: theme.textTheme.labelLarge),
                              Wrap(
                                spacing: 12.0,
                                runSpacing: 12.0,
                                children: InveslyAccountIcon.values.map((iconOption) {
                                  final isSelected = cubit.state.iconName == iconOption.name;
                                  return InkWell(
                                    borderRadius: BorderRadius.circular(999.0),
                                    onTap: () => cubit.updateIcon(iconOption.name),
                                    child: Container(
                                      width: 48.0,
                                      height: 48.0,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? selectedColor.withAlpha(0x33)
                                            : theme.colorScheme.surfaceContainerHighest,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isSelected ? selectedColor : theme.colorScheme.outlineVariant,
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: Icon(
                                        iconOption.iconData,
                                        color: isSelected ? selectedColor : theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 12.0,
                            children: <Widget>[
                              Text('Color', style: theme.textTheme.labelLarge),
                              InkWell(
                                borderRadius: BorderRadius.circular(16.0),
                                onTap: () async {
                                  final color = await InveslyColorPickerWidget.showModal(
                                    context,
                                    selectedColor: selectedColor,
                                  );
                                  if (color != null && context.mounted) {
                                    cubit.updateColor(color.toARGB32());
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                                  decoration: BoxDecoration(
                                    color: selectedColor.withAlpha(0x33),
                                    borderRadius: BorderRadius.circular(16.0),
                                    border: Border.all(color: selectedColor),
                                  ),
                                  child: Row(
                                    children: <Widget>[
                                      Container(
                                        width: 24.0,
                                        height: 24.0,
                                        decoration: BoxDecoration(color: selectedColor, shape: BoxShape.circle),
                                      ),
                                      const Gap(12.0),
                                      Text('Tap to choose a color', style: theme.textTheme.bodyMedium),
                                    ],
                                  ),
                                ),
                              ),
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

// class ScrollBasedSliverAppBarContentBuilder extends StatefulWidget {
//   const ScrollBasedSliverAppBarContentBuilder({super.key, required this.builder});

//   final Widget Function(BuildContext context, double opacity) builder;

//   @override
//   State<ScrollBasedSliverAppBarContentBuilder> createState() => _ScrollBasedSliverAppBarContentBuilderState();
// }

// class _ScrollBasedSliverAppBarContentBuilderState extends State<ScrollBasedSliverAppBarContentBuilder> {
//   ScrollPosition? _position;
//   late final FlexibleSpaceBarSettings settings;
//   late final ValueNotifier<double> _opacityNotifier;

//   @override
//   void initState() {
//     super.initState();
//     _opacityNotifier = ValueNotifier(0);
//     settings = context.getInheritedWidgetOfExactType<FlexibleSpaceBarSettings>()!;
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();

//     if (_position != null) {
//       _position!.removeListener(_positionListener);
//     }
//     _position = Scrollable.maybeOf(context)?.position;
//     if (_position != null) {
//       _position!.addListener(_positionListener);
//     }
//   }

//   @override
//   void dispose() {
//     if (_position != null) {
//       _position!.removeListener(_positionListener);
//     }
//     super.dispose();
//   }

//   void _positionListener() {
//     _opacityNotifier.value = ((_position!.extentBefore - settings.minExtent) / 100).clamp(0.0, 1.0);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ValueListenableBuilder<double>(
//       valueListenable: _opacityNotifier,
//       builder: (context, value, _) {
//         return widget.builder(context, value);
//       },
//     );
//   }
// }
