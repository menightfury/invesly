// import 'package:invesly/common/components/numeric_keyboard.dart';

import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import 'package:invesly/amcs/model/amc_model.dart';
import 'package:invesly/common/extensions/widget_extension.dart';
import 'package:invesly/common/presentations/animations/shake.dart';
import 'package:invesly/common/presentations/widgets/async_form_field.dart';
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
      // if (!(_quantityTextField.currentState?.isValid ?? false)) {
      //   _quantityShakeKey.currentState?.shake();
      // }

      // if (!(_amountTextField.currentState?.isValid ?? false)) {
      //   _amountShakeKey.currentState?.shake();
      // }
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
                                child: AsyncFormField<double>(
                                  initialValue: cubit.state.quantity,
                                  validator: (value) {
                                    if (value == null || value.isNegative) {
                                      return 'Can\'t be empty or negative';
                                    }
                                    return null;
                                  },
                                  onTapCallback: () async {
                                    final value = await InveslyCalculatorWidget.showModal(context);
                                    if (value == null) return null;
                                    cubit.updateQuantity(value);
                                    return value;
                                  },
                                  childBuilder: (value) {
                                    if (value == null) {
                                      return const Text(
                                        'Select units',
                                        style: TextStyle(color: Colors.grey),
                                        overflow: TextOverflow.ellipsis,
                                      );
                                    }
                                    return Text(
                                      NumberFormat.decimalPattern('en_IN').format(value),
                                      textAlign: TextAlign.right,
                                      overflow: TextOverflow.ellipsis,
                                    );
                                  },
                                ).withLabel('No. of units'),
                              ),

                              // ~ Amount
                              Expanded(
                                child: AsyncFormField<double>(
                                  initialValue: cubit.state.amount,
                                  validator: (value) {
                                    if (value == null || value.isNegative) {
                                      return 'Can\'t be empty or negative';
                                    }
                                    return null;
                                  },
                                  onTapCallback: () async {
                                    final value = await InveslyCalculatorWidget.showModal(context);
                                    if (value == null) return null;
                                    cubit.updateAmount(value);
                                    return value;
                                  },
                                  childBuilder: (value) {
                                    if (value == null) {
                                      return const Text(
                                        'Select units',
                                        style: TextStyle(color: Colors.grey),
                                        overflow: TextOverflow.ellipsis,
                                      );
                                    }
                                    return Text(
                                      NumberFormat.decimalPattern('en_IN').format(value),
                                      textAlign: TextAlign.right,
                                      overflow: TextOverflow.ellipsis,
                                    );
                                  },
                                ).withLabel('Total amount'),
                              ),
                            ],
                          ),

                          // ~~~ AMC ~~~
                          AsyncFormField<InveslyAmc>(
                            initialValue: cubit.state.amc,
                            validator: (value) {
                              if (value == null) {
                                return 'Can\'t be empty';
                              }
                              return null;
                            },
                            onTapCallback: () async {
                              final value = await InveslyAmcPickerWidget.showModal(context);
                              if (value == null) return null;
                              cubit.updateAmc(value);
                              return value;
                            },
                            childBuilder: (value) {
                              if (value == null) {
                                return const Text('Select AMC', style: TextStyle(color: Colors.grey));
                              }
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(value.name, overflow: TextOverflow.ellipsis),
                                  Text(
                                    (value.genre ?? AmcGenre.misc).title,
                                    style: context.textTheme.labelSmall,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              );
                            },
                          ).withLabel('Asset management company (AMC)'),

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
