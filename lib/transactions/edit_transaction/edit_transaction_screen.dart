// import 'package:invesly/common/components/numeric_keyboard.dart';

import 'dart:async';

import 'package:intl/intl.dart';
import 'package:invesly/common/extensions/widget_extension.dart';
import 'package:invesly/common/presentations/animations/shake_widget.dart';
import 'package:invesly/transactions/dashboard/view/dashboard_screen.dart';
import 'package:invesly/transactions/edit_transaction/widgets/calculator/calculator.dart';
import 'package:pattern_formatter/numeric_formatter.dart';

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
          (context) => EditInvestmentCubit(
            repository: context.read<TransactionRepository>(),
            initialInvestment: initialTransaction,
          ),
      child: const _EditInvestmentScreen(),
    );
  }
}

class _EditInvestmentScreen extends StatefulWidget {
  const _EditInvestmentScreen({super.key});

  @override
  State<_EditInvestmentScreen> createState() => __EditInvestmentScreenState();
}

class __EditInvestmentScreenState extends State<_EditInvestmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _shakeKey = GlobalKey<ShakeWidgetState>();
  late final ValueNotifier<AutovalidateMode> _validateMode;

  @override
  void initState() {
    super.initState();
    _validateMode = ValueNotifier(AutovalidateMode.disabled);
  }

  @override
  void dispose() {
    _formKey.currentState?.reset();
    _validateMode.dispose();
    super.dispose();
  }

  Future<void> _handleSavePressed(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      await context.read<EditInvestmentCubit>().save();
      if (!context.mounted) return;

      const message = SnackBar(content: Text('Investment saved successfully.'), backgroundColor: Colors.teal);
      ScaffoldMessenger.of(context).showSnackBar(message);

      Navigator.maybePop<bool>(context);
    } else {
      _shakeKey.currentState?.shake();
      if (_validateMode.value != AutovalidateMode.always) {
        _validateMode.value = AutovalidateMode.always;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<EditInvestmentCubit>();

    return BlocListener<EditInvestmentCubit, EditTransactionState>(
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
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
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
                            Row(
                              spacing: 12.0,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                // ~ Units
                                Expanded(
                                  child: ShakeWidget(
                                    key: _shakeKey,
                                    // child: TextFormField(
                                    //   decoration: const InputDecoration(hintText: 'e.g. 5'),
                                    //   textAlign: TextAlign.end,
                                    //   keyboardType: const TextInputType.numberWithOptions(),
                                    //   inputFormatters: [
                                    //     ThousandsFormatter(
                                    //       allowFraction: true,
                                    //       formatter: NumberFormat.decimalPattern('en_IN'),
                                    //     ),
                                    //   ],
                                    //   validator: (value) {
                                    //     if (value == null || !value.isValidText) return 'This field can\'t be empty';

                                    //     return null;
                                    //   },
                                    //   onChanged: (value) {
                                    //     cubit.updateQuantity(double.tryParse(value.trim().replaceAll(',', '')) ?? 0.0);
                                    //   },
                                    // ).withLabel('No. of units'),
                                    child: Tappable(
                                      onTap: () async {
                                        final value = await InveslyCalculatorWidget.showModal(context);
                                        $logger.d(value);
                                        if (value == null) return;
                                        cubit.updateQuantity(value);
                                      },
                                      childAlignment: Alignment.centerRight,
                                      child:
                                          cubit.state.quantity != null
                                              ? Text(NumberFormat.decimalPattern('en_IN').format(cubit.state.quantity))
                                              : Text('e.g. 5', style: TextStyle(color: Colors.grey)),
                                    ).withLabel('No. of units'),
                                  ),
                                ),

                                // ~ Price
                                Expanded(
                                  child: TextFormField(
                                    decoration: const InputDecoration(
                                      hintText: 'e.g. 500',
                                      prefixText: '₹ ',
                                      prefixStyle: TextStyle(color: Colors.black),
                                    ),
                                    textAlign: TextAlign.end,
                                    keyboardType: const TextInputType.numberWithOptions(),
                                    inputFormatters: [
                                      ThousandsFormatter(
                                        allowFraction: true,
                                        formatter: NumberFormat.decimalPattern('en_IN'),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      cubit.updateAmount(value.trim().replaceAll(',', '').parseDouble ?? 0.0);
                                    },
                                  ).withLabel('Total amount'),
                                ),
                              ],
                            ),

                            // ~~~ AMC picker ~~~
                            Tappable(
                              onTap: () async {
                                final amc = await InveslyAmcPickerWidget.showModal(context);
                                if (amc != null) {
                                  cubit.updateAmc(amc);
                                }
                              },
                              child: const Text('Asset Management Company', overflow: TextOverflow.ellipsis),
                            ).withLabel('Asset management company (AMC)'),

                            Row(
                              spacing: 12.0,
                              children: <Widget>[
                                // ~ Type selection
                                Expanded(child: InveslyTogglerExample().withLabel('Transaction type')),

                                // ~~~ Date picker ~~~
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
                            ).withLabel('Note'),
                          ],
                        ),
                      ),
                    ]),
                  ),

                  // ~~~ Save button ~~~
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.save_alt_rounded),
                          onPressed: () => _handleSavePressed(context),
                          label: const Text('Save transaction'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UserPickerWidget extends StatelessWidget {
  const _UserPickerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<EditInvestmentCubit>();

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
