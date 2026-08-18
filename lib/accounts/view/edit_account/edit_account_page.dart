import 'package:invesly/accounts/view/edit_account/cubit/edit_account_cubit.dart';
import 'package:invesly/accounts/model/account_model.dart';
import 'package:invesly/accounts/model/account_repository.dart';
import 'package:invesly/common/extensions/color_extension.dart';
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
                SliverAppBar(
                  snap: true,
                  floating: true,
                  title: Text('${cubit.state.isNewAccount ? 'Add' : 'Edit'} Account'),
                  // Text('Welcome,', style: context.textTheme.headlineSmall),
                  // BlocSelector<EditAccountCubit, EditAccountState, String?>(
                  //   selector: (state) => state.name,
                  //   builder: (context, name) {
                  //     return Text(
                  //       name == null || name.trim().isEmpty ? 'Investor' : name,
                  //       style: context.textTheme.headlineMedium,
                  //     );
                  //   },
                  // ),
                ),

                // ~ Preview
                // SliverToBoxAdapter(
                //   child: Padding(
                //     padding: const EdgeInsets.symmetric(horizontal: 16.0),
                //     child: Row(
                //       children: <Widget>[
                //         Container(
                //           width: 72.0,
                //           height: 72.0,
                //           decoration: BoxDecoration(color: selectedColor.withAlpha(0x33), shape: BoxShape.circle),
                //           alignment: Alignment.center,
                //           child: Icon(
                //             InveslyAccountIcon.fromName(cubit.state.iconName).data,
                //             size: 32.0,
                //             color: selectedColor,
                //           ),
                //         ),
                //         const Gap(16.0),
                //         Expanded(
                //           child: Column(
                //             crossAxisAlignment: CrossAxisAlignment.start,
                //             children: <Widget>[
                //               Text('Preview', style: context.textTheme.labelLarge),
                //               Text(
                //                 cubit.state.name?.trim().isEmpty == true
                //                     ? 'Account title'
                //                     : cubit.state.name ?? 'Account title',
                //                 style: context.textTheme.titleMedium,
                //               ),
                //             ],
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),

                // const SliverGap(12.0),

                // ~ Name
                SliverToBoxAdapter(
                  child: Padding(
                    padding: iPaddingFromScreenEdge,
                    child: BlocBuilder<EditAccountCubit, EditAccountState>(
                      buildWhen: (prev, curr) {
                        return prev.nameError != curr.nameError || (prev.status != curr.status && curr.isError);
                      },
                      builder: (context, state) {
                        final isError = state.nameError != null;
                        return Shake(
                          shake: isError,
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'e.g. Savings account',
                              helperText: cubit.state.isNewAccount ? 'Name can\'t be changed later' : null,
                              errorText: state.nameError,
                            ),
                            controller: _nameController,
                            onChanged: cubit.updateName,
                            enabled: cubit.state.isNewAccount,
                            onTapOutside: (_) => minimizeKeyboard(),
                          ),
                        );
                      },
                    ).withLabel('Name'),
                  ),
                ),

                const SliverGap(iFormFieldsInterSpacing),

                // ~ Description
                SliverToBoxAdapter(
                  child: Padding(
                    padding: iPaddingFromScreenEdge,
                    child: TextField(
                      maxLines: 3,
                      controller: _descriptionController,
                      decoration: const InputDecoration(hintText: 'Optional, e.g. My savings account'),
                      onChanged: cubit.updateDescription,
                      onTapOutside: (_) => minimizeKeyboard(),
                    ).withLabel('Description'),
                  ),
                ),

                const SliverGap(iFormFieldsInterSpacing),

                // ~ Color Picker
                SliverToBoxAdapter(
                  child: Padding(
                    padding: iPaddingFromScreenEdge,
                    child: BlocSelector<EditAccountCubit, EditAccountState, Color>(
                      selector: (state) => state.color,
                      builder: (context, color) {
                        return InveslyColorPickerWidget(
                          selectedColor: color,
                          onPickup: (value) => cubit.updateColor(value),
                        );
                      },
                    ).withLabel('Color'),
                  ),
                ),

                const SliverGap(iFormFieldsInterSpacing),

                // ~ Icon Picker
                SliverToBoxAdapter(
                  child: Padding(
                    padding: iPaddingFromScreenEdge,
                    child: BlocBuilder<EditAccountCubit, EditAccountState>(
                      buildWhen: (prev, curr) => prev.color != curr.color || prev.icon != curr.icon,
                      builder: (context, state) {
                        return Wrap(
                          spacing: 12.0,
                          runSpacing: 12.0,
                          children: InveslyAccountIcon.values.map((icon) {
                            final isSelected = state.icon == icon;
                            return GestureDetector(
                              onTap: () => cubit.updateIcon(icon),
                              child: icon.buildWidget(
                                context,
                                padding: 12.0,
                                color: isSelected ? cubit.state.color : context.colors.onSurfaceVariant,
                                backgroundColor: isSelected
                                    ? cubit.state.color.lighten(80)
                                    : context.colors.surfaceContainerHighest,
                                border: isSelected ? Border.all(color: cubit.state.color) : null,
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ).withLabel('Icon'),
                  ),
                ),

                const SliverGap(iFormFieldsInterSpacing),
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
