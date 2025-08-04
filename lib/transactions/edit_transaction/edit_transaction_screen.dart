// import 'package:invesly/common/components/numeric_keyboard.dart';

import 'dart:async';

import 'package:intl/intl.dart';
import 'package:invesly/amcs/model/amc_model.dart';
import 'package:invesly/common/extensions/widget_extension.dart';
import 'package:invesly/common/presentations/animations/shake.dart';
import 'package:invesly/common/presentations/components/tappable_form_field.dart';
import 'package:invesly/transactions/dashboard/view/dashboard_screen.dart';
import 'package:invesly/transactions/edit_transaction/widgets/calculator/calculator.dart';

import 'package:invesly/amcs/view/widgets/amc_picker_widget.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/transactions/model/transaction_model.dart';
import 'package:invesly/transactions/model/transaction_repository.dart';
import 'package:invesly/users/cubit/users_cubit.dart';
import 'package:invesly/users/widget/user_picker_widget.dart';

import 'cubit/edit_transaction_cubit.dart';

class EditTransactionScreen extends StatelessWidget {
  const EditTransactionScreen({super.key, this.initialTransaction});

  final InveslyTransaction? initialTransaction;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) => EditTransactionCubit(
            repository: context.read<TransactionRepository>(),
            initialInvestment: initialTransaction,
          ),
      child: const _EditTransactionScreen(),
    );
  }
}

class _EditTransactionScreen extends StatefulWidget {
  const _EditTransactionScreen({super.key});

  @override
  State<_EditTransactionScreen> createState() => __EditTransactionScreenState();
}

class __EditTransactionScreenState extends State<_EditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityShakeKey = GlobalKey<ShakeState>();
  final _quantityTextField = GlobalKey<FormFieldState>();
  final _amountShakeKey = GlobalKey<ShakeState>();
  final _amountTextField = GlobalKey<FormFieldState>();

  late final TextEditingController _quantityTextController;
  late final TextEditingController _amountTextController;
  late final ValueNotifier<AutovalidateMode> _validateMode;

  @override
  void initState() {
    super.initState();
    _quantityTextController = TextEditingController();
    _amountTextController = TextEditingController();
    _validateMode = ValueNotifier(AutovalidateMode.disabled);
  }

  @override
  void dispose() {
    _formKey.currentState?.reset();
    _validateMode.dispose();
    _quantityTextController.dispose();
    _amountTextController.dispose();
    super.dispose();
  }

  Future<void> _handleSavePressed(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      await context.read<EditTransactionCubit>().save();
      if (!context.mounted) return;

      const message = SnackBar(content: Text('Investment saved successfully.'), backgroundColor: Colors.teal);
      ScaffoldMessenger.of(context).showSnackBar(message);

      Navigator.maybePop<bool>(context);
    } else {
      if (!(_quantityTextField.currentState?.isValid ?? false)) {
        _quantityShakeKey.currentState?.shake();
      }

      if (!(_amountTextField.currentState?.isValid ?? false)) {
        _amountShakeKey.currentState?.shake();
      }
      if (_validateMode.value != AutovalidateMode.onUserInteraction) {
        _validateMode.value = AutovalidateMode.onUserInteraction;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<EditTransactionCubit>();

    return BlocListener<EditTransactionCubit, EditTransactionState>(
      listenWhen: (prevState, state) => prevState.status != state.status && state.status.isFailureOrSuccess,
      listener: (context, state) {
        late final SnackBar message;

        if (state.status == EditTransactionStatus.success) {
          if (context.canPop) {
            context.pop();
          } else {
            // context.go(AppRouter.dashboard);
            context.go(DashboardScreen());
          }
          message = const SnackBar(content: Text('Investment saved successfully'), backgroundColor: Colors.teal);
        } else if (state.status == EditTransactionStatus.failure) {
          message = const SnackBar(content: Text('Sorry! some error occurred'), backgroundColor: Colors.redAccent);
        }
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(message);
      },
      child: Scaffold(
        // ~ Form
        body: SafeArea(
          child: ValueListenableBuilder<AutovalidateMode>(
            valueListenable: _validateMode,
            builder: (context, validateMode, child) {
              return Form(key: _formKey, autovalidateMode: validateMode, child: child!);
            },
            child: CustomScrollView(
              slivers: <Widget>[
                SliverAppBar(pinned: true, floating: true, actions: [_UserPickerWidget()]),

                SliverList(
                  delegate: SliverChildListDelegate.fixed(<Widget>[
                    // ~ Title
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(cubit.state.isNewTransaction ? 'Add' : 'Edit', style: context.textTheme.headlineSmall),
                          Text('Transaction', style: context.textTheme.headlineMedium),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12.0),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        spacing: 12.0,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ~~~ Units and Amount ~~~
                          Row(
                            spacing: 12.0,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              // ~ Units
                              Expanded(
                                child: Shake(
                                  key: _quantityShakeKey,
                                  child: TextFormField(
                                    key: _quantityTextField,
                                    // controller: TextEditingController(text: quantity?.toString()),
                                    controller: _quantityTextController,
                                    decoration: const InputDecoration(hintText: 'e.g. 5'),
                                    textAlign: TextAlign.right,
                                    readOnly: true,
                                    // keyboardType: const TextInputType.numberWithOptions(),
                                    // inputFormatters: [
                                    //   ThousandsFormatter(
                                    //     allowFraction: true,
                                    //     formatter: NumberFormat.decimalPattern('en_IN'),
                                    //   ),
                                    // ],
                                    validator: (value) {
                                      if (value == null || !value.isValidText) {
                                        return 'Can\'t be empty';
                                      }
                                      return null;
                                    },
                                    // onChanged: (value) {
                                    //   cubit.updateQuantity(value.trim().replaceAll(',', '').parseDouble ?? 0.0);
                                    // },
                                    onTap: () async {
                                      final value = await InveslyCalculatorWidget.showModal(context);
                                      if (value == null) return;
                                      _quantityTextController.text = NumberFormat.decimalPattern('en_IN').format(value);
                                      cubit.updateQuantity(value);
                                    },
                                    onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
                                  ).withLabel('No. of units'),
                                ),
                              ),

                              // ~ Amount
                              Expanded(
                                child: Shake(
                                  key: _amountShakeKey,
                                  child: TextFormField(
                                    key: _amountTextField,
                                    controller: _amountTextController,
                                    decoration: const InputDecoration(
                                      hintText: 'e.g. 500',
                                      prefixText: '₹ ',
                                      prefixStyle: TextStyle(color: Colors.black),
                                    ),
                                    textAlign: TextAlign.end,
                                    readOnly: true,
                                    // keyboardType: const TextInputType.numberWithOptions(),
                                    // inputFormatters: [
                                    //   ThousandsFormatter(
                                    //     allowFraction: true,
                                    //     formatter: NumberFormat.decimalPattern('en_IN'),
                                    //   ),
                                    // ],
                                    validator: (value) {
                                      if (value == null || !value.isValidText) {
                                        return 'Can\'t be empty';
                                      }
                                      return null;
                                    },
                                    // onChanged: (value) {
                                    //   cubit.updateAmount(value.trim().replaceAll(',', '').parseDouble ?? 0.0);
                                    // },
                                    onTap: () async {
                                      final value = await InveslyCalculatorWidget.showModal(context);
                                      if (value == null) return;
                                      _amountTextController.text = NumberFormat.decimalPattern('en_IN').format(value);
                                      cubit.updateAmount(value);
                                    },
                                    onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
                                  ).withLabel('Total amount'),
                                ),
                              ),
                            ],
                          ),

                          // ~~~ AMC picker ~~~
                          _AmcFormField(
                            validator: (value) {
                              $logger.d(value);
                              if (value == null) {
                                return 'AMC can\'t be empty';
                              }
                              return null;
                            },
                          ),
                          // BlocSelector<EditTransactionCubit, EditTransactionState, InveslyAmc?>(
                          //   selector: (state) => state.amc,
                          //   builder: (context, amc) {
                          //     return TappableFormField<InveslyAmc>(
                          //       value: amc,
                          //       onTap: () async {
                          //         final amc = await InveslyAmcPickerWidget.showModal(context);
                          //         if (amc == null) return;
                          //         cubit.updateAmc(amc);
                          //       },
                          //       validator: (value) {
                          //         $logger.d(value);
                          //         if (value == null) {
                          //           return 'AMC can\'t be empty';
                          //         }
                          //         return null;
                          //       },
                          //       childBuilder: (newAmc) {
                          //         if (newAmc == null) {
                          //           return const Text('Select AMC', style: TextStyle(color: Colors.grey));
                          //         }
                          //         return Column(
                          //           mainAxisSize: MainAxisSize.min,
                          //           crossAxisAlignment: CrossAxisAlignment.start,
                          //           children: <Widget>[
                          //             Text(newAmc.name, overflow: TextOverflow.ellipsis),
                          //             Text(
                          //               (newAmc.genre ?? AmcGenre.misc).title,
                          //               style: context.textTheme.labelSmall,
                          //               overflow: TextOverflow.ellipsis,
                          //             ),
                          //           ],
                          //         );
                          //       },
                          //     ).withLabel('Asset management company (AMC)');
                          //   },
                          // ),

                          // ~~~ Type and Date ~~~
                          Row(
                            spacing: 12.0,
                            children: <Widget>[
                              // ~ Type ~
                              Expanded(child: InveslyTogglerExample().withLabel('Transaction type')),

                              // ~ Date ~
                              Expanded(
                                child: InveslyDatePicker(
                                  date: cubit.state.date,
                                  onPickup: (value) => cubit.updateDate(value),
                                ).withLabel('Transaction date'),
                              ),
                            ],
                          ),

                          // ~~~ Note ~~~
                          TextFormField(
                            decoration: const InputDecoration(hintText: 'Notes'),
                            onChanged: (value) => cubit.updateNotes(value),
                            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
                          ).withLabel('Note'),
                        ],
                      ),
                    ),
                  ]),
                ),

                // // ~~~ Save button ~~~
                // SliverFillRemaining(
                //   hasScrollBody: false,
                //   child: Align(
                //     alignment: Alignment.bottomCenter,
                //     child: Padding(
                //       padding: const EdgeInsets.symmetric(vertical: 8.0),
                //       child: ElevatedButton.icon(
                //         icon: const Icon(Icons.save_alt_rounded),
                //         onPressed: () => _handleSavePressed(context),
                //         label: const Text('Save transaction'),
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
        persistentFooterButtons: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save_alt_rounded),
                onPressed: () => _handleSavePressed(context),
                label: const Text('Save transaction'),
              ),
            ),
          ),
        ],
        persistentFooterAlignment: AlignmentDirectional.center,
      ),
    );
  }
}

class _UserPickerWidget extends StatelessWidget {
  const _UserPickerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<EditTransactionCubit>();

    return IconButton(
      onPressed: () async {
        final newUser = await InveslyUserPickerWidget.showModal(context, cubit.state.userId);
        if (newUser == null) return;

        cubit.updateUser(newUser);
      },
      icon: BlocBuilder<UsersCubit, UsersState>(
        builder: (context, state) {
          if (state is UsersErrorState) {
            return const Icon(Icons.error_outline_rounded, color: Colors.redAccent);
          }

          if (state is UsersLoadedState) {
            final users = state.users;
            final currentUser = users.isEmpty ? null : users.firstWhereOrNull((u) => u.id == cubit.state.userId);

            return CircleAvatar(
              foregroundImage: currentUser != null ? AssetImage(currentUser.avatar) : null,
              radius: 20.0,
              child: Text(currentUser?.name.substring(0, 1).toUpperCase() ?? '?'),
            );
          }

          return const CircularProgressIndicator();
        },
      ),
    );
  }
}

class InveslyTogglerExample extends StatefulWidget {
  const InveslyTogglerExample({super.key});

  @override
  State<InveslyTogglerExample> createState() => _InveslyTogglerExampleState();
}

class _AmcFormField extends FormField<InveslyAmc> {
  _AmcFormField({
    super.key,
    InveslyAmc? value,
    super.forceErrorText,
    super.onSaved,
    super.validator,
    AutovalidateMode? autovalidateMode,
    super.errorBuilder,
    EdgeInsetsGeometry padding = const EdgeInsetsGeometry.symmetric(horizontal: 12.0),
    AlignmentGeometry contentAlignment = Alignment.centerLeft,
    super.restorationId,
  }) : super(
         autovalidateMode: autovalidateMode ?? AutovalidateMode.disabled,
         initialValue: value,
         builder: (FormFieldState<InveslyAmc> field) {
           final state = field as __AmcFormFieldState;
           final theme = Theme.of(state.context);
           final colors = theme.colorScheme;

           final errorText = state.errorText;
           Widget? error;
           if (errorText != null && errorBuilder != null) {
             error = errorBuilder(state.context, errorText);
           }

           TextStyle errorStyle = theme.textTheme.bodySmall ?? const TextStyle();
           errorStyle = errorStyle.copyWith(color: colors.error).merge(theme.inputDecorationTheme.errorStyle);

           if (error != null) {
             state._controller.forward();
           } else {
             state._controller.reverse();
           }

           final amc = state.value;
           late final Widget content;
           if (amc == null) {
             content = Text('Select AMC', style: TextStyle(color: Colors.grey));
           } else {
             content = Column(
               mainAxisSize: MainAxisSize.min,
               crossAxisAlignment: CrossAxisAlignment.start,
               children: <Widget>[
                 Text(amc.name, overflow: TextOverflow.ellipsis),
                 Text(
                   (amc.genre ?? AmcGenre.misc).title,
                   style: theme.textTheme.labelSmall,
                   overflow: TextOverflow.ellipsis,
                 ),
               ],
             );
           }

           return Shake(
             //  shake: field.hasError,
             shake: false,
             child: Column(
               mainAxisSize: MainAxisSize.min,
               crossAxisAlignment: CrossAxisAlignment.start,
               spacing: 4.0,
               children: <Widget>[
                 Tappable(
                   onTap: () async {
                     final amc = await InveslyAmcPickerWidget.showModal(state.context);
                     if (amc == null) return;
                     //  cubit.updateAmc(amc);
                   },
                   childAlignment: contentAlignment,
                   padding: padding,
                   bgColor: errorText != null ? colors.errorContainer : colors.primaryContainer,
                   child: content,
                 ),
                 //  if (state.hasError)
                 //  Padding(
                 //    padding: padding,
                 //    child: _ErrorViewer(error: error, errorText: errorText, errorStyle: errorStyle),
                 //  ),
                 if (state.hasError)
                   FadeTransition(
                     opacity: state._controller,
                     child: FractionalTranslation(
                       translation: Tween<Offset>(
                         begin: const Offset(0.0, -0.25),
                         end: Offset.zero,
                       ).evaluate(state._controller.view),
                       child:
                           error ??
                           Text(
                             errorText!,
                             style: errorStyle,
                             //  textAlign: textAlign,
                             overflow: TextOverflow.ellipsis,
                             //  maxLines: widget.errorMaxLines,
                           ),
                     ),
                   ),
               ],
             ),
           );
         },
       );

  // final ValueChanged<String>? onChanged;

  @override
  FormFieldState<InveslyAmc> createState() => __AmcFormFieldState();
}

class __AmcFormFieldState extends FormFieldState<InveslyAmc> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  _AmcFormField get _field => super.widget as _AmcFormField;
  bool get _hasError => errorText != null;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: 167.ms, vsync: this);
    if (_hasError) {
      _controller.value = 1.0;
    }
    // _controller.addListener(_handleChange);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // @override
  // void didUpdateWidget(_AmcFormField old) {
  //   super.didUpdateWidget(old);

  //   final String? newErrorText = errorText;
  //   final String? oldErrorText = old.errorText;

  //   final bool errorStateChanged = (newError != null) != (oldError != null);
  //   final bool errorTextStateChanged = (newErrorText != null) != (oldErrorText != null);

  //   if (errorStateChanged || errorTextStateChanged) {
  //     if (newError != null || newErrorText != null) {
  //       _controller.forward();
  //     } else {
  //       _controller.reverse();
  //     }
  //   }
  // }
}

class _ErrorViewer extends StatefulWidget {
  const _ErrorViewer({this.textAlign, this.error, this.errorText, this.errorStyle, this.errorMaxLines});

  final TextAlign? textAlign;
  final Widget? error;
  final String? errorText;
  final TextStyle? errorStyle;
  final int? errorMaxLines;

  @override
  _ErrorViewerState createState() => _ErrorViewerState();
}

class _ErrorViewerState extends State<_ErrorViewer> with SingleTickerProviderStateMixin {
  // If the height of this widget and the counter are zero ("empty") at
  // layout time, no space is allocated for the subtext.
  static const Widget empty = SizedBox.shrink();

  late AnimationController _controller;
  bool get _hasError => widget.errorText != null || widget.error != null;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: Duration(milliseconds: 167), vsync: this);
    if (_hasError) {
      _controller.value = 1.0;
    }
    _controller.addListener(_handleChange);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleChange() {
    setState(() {
      // The _controller's value has changed.
    });
  }

  @override
  void didUpdateWidget(_ErrorViewer old) {
    super.didUpdateWidget(old);

    final Widget? newError = widget.error;
    final String? newErrorText = widget.errorText;
    final Widget? oldError = old.error;
    final String? oldErrorText = old.errorText;

    final bool errorStateChanged = (newError != null) != (oldError != null);
    final bool errorTextStateChanged = (newErrorText != null) != (oldErrorText != null);

    if (errorStateChanged || errorTextStateChanged) {
      if (newError != null || newErrorText != null) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  Widget _buildError() {
    assert(widget.error != null || widget.errorText != null);
    return FadeTransition(
      opacity: _controller,
      child: FractionalTranslation(
        translation: Tween<Offset>(begin: const Offset(0.0, -0.25), end: Offset.zero).evaluate(_controller.view),
        child:
            widget.error ??
            Text(
              widget.errorText!,
              style: widget.errorStyle,
              textAlign: widget.textAlign,
              overflow: TextOverflow.ellipsis,
              maxLines: widget.errorMaxLines,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.isDismissed) {
      return empty;
    }

    if (_controller.isCompleted) {
      if (_hasError) {
        return _buildError();
      }
      return empty;
    }

    if (_hasError) {
      return _buildError();
    }

    return empty;
  }
}

class _InveslyTogglerExampleState extends State<InveslyTogglerExample> {
  late TransactionType _value;

  @override
  void initState() {
    super.initState();
    _value = TransactionType.values.first;
  }

  @override
  Widget build(BuildContext context) {
    return InveslyToggler<TransactionType>(
      value: _value,
      displayStringForOption: (option) => option.name.toSentenceCase(),
      options: TransactionType.values.toSet(),
      onChanged: (value) => setState(() => _value = value),
    );
  }
}

class InveslyToggler<T> extends StatelessWidget {
  InveslyToggler({
    super.key,
    required this.options,
    this.value,
    this.displayStringForOption = _defaultStringForOption,
    this.onChanged,
  }) : assert(options.isNotEmpty);

  final Set<T> options;
  final T? value;
  final ValueChanged<T>? onChanged;
  final String Function(T option) displayStringForOption;

  static String _defaultStringForOption(Object? option) => option.toString();

  @override
  Widget build(BuildContext context) {
    // final colorScheme = Theme.of(context).colorScheme;
    int index = value == null ? 0 : options.toList(growable: false).indexOf(value as T);

    if (index == -1) {
      index = 0;
    }
    final option = options.elementAt(index);

    return Tappable(
      onTap: () {
        final nextIndex = index < (options.length - 1) ? index + 1 : 0;
        onChanged?.call(options.elementAt(nextIndex));
      },
      leading: const Icon(Icons.chevron_left_rounded),
      trailing: const Icon(Icons.chevron_right_rounded),
      child: Text(displayStringForOption(option), overflow: TextOverflow.clip, maxLines: 1, softWrap: false),
    );
  }
}

// class _NotesEditor extends StatefulWidget {
//   final String? initialNote;
//   final ValueChanged<String>? onSubmit;

//   const _NotesEditor({super.key, this.initialNote, this.onSubmit});

//   @override
//   State<_NotesEditor> createState() => __NotesEditorState();
// }

// class __NotesEditorState extends State<_NotesEditor> {
//   late final TextEditingController _notesController;

//   @override
//   void initState() {
//     super.initState();
//     _notesController = TextEditingController(text: widget.initialNote);
//   }

//   @override
//   void dispose() {
//     _notesController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

//     return Padding(
//       padding: const EdgeInsets.all(16.0).copyWith(bottom: 16.0 + bottomPadding),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         // crossAxisAlignment: CrossAxisAlignment.start,
//         children: <Widget>[
//           const Text('Add note', textAlign: TextAlign.center),
//           const Gap(12.0),
//           TextFormField(
//             decoration: const InputDecoration(hintText: 'Add notes'),
//             controller: _notesController,
//             autofocus: true,
//           ),
//           const Gap(12.0),
//           Align(
//             alignment: Alignment.bottomRight,
//             child: ElevatedButton.icon(
//               onPressed: () => widget.onSubmit?.call(_notesController.text),
//               icon: const Icon(Icons.check_rounded),
//               label: const Text('Confirm'),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
