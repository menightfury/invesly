import 'dart:async';

import 'package:intl/intl.dart';
import 'package:invesly/amcs/model/amc_model.dart';
import 'package:invesly/common/extensions/widget_extension.dart';
import 'package:invesly/common/presentations/animations/fade_in.dart';
import 'package:invesly/common/presentations/animations/fade_out.dart';
import 'package:invesly/common/presentations/animations/shake.dart';
import 'package:invesly/common/presentations/widgets/async_form_field.dart';
import 'package:invesly/common/utils/keyboard.dart';
import 'package:invesly/transactions/dashboard/view/dashboard_screen.dart';
import 'package:invesly/transactions/edit_transaction/widgets/calculator/calculator.dart';

import 'package:invesly/amcs/view/widgets/amc_picker_widget.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/transactions/model/transaction_model.dart';
import 'package:invesly/transactions/model/transaction_repository.dart';
import 'package:invesly/accounts/cubit/accounts_cubit.dart';
import 'package:invesly/accounts/model/account_model.dart';
import 'package:invesly/accounts/widget/account_picker_widget.dart';

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
  late final ValueNotifier<AutovalidateMode> _validateMode;
  late final DateTime _dateNow;

  final _types = TransactionType.values;

  @override
  void initState() {
    super.initState();
    _validateMode = ValueNotifier(AutovalidateMode.disabled);
    _dateNow = DateTime.now();
  }

  @override
  void dispose() {
    _formKey.currentState?.reset();
    _validateMode.dispose();
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
                                    if (value == null) {
                                      return 'Can\'t be empty';
                                    }
                                    if (value.isNegative) {
                                      return 'Can\'t be negative';
                                    }
                                    return null;
                                  },
                                  onTapCallback: () async {
                                    final value = await InveslyCalculatorWidget.showModal(context);
                                    if (value == null) return null;
                                    return value;
                                  },
                                  onChanged: (value) {
                                    if (value == null) return;
                                    cubit.updateQuantity(value);
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
                                    return value;
                                  },

                                  onChanged: (value) {
                                    if (value == null) return;
                                    cubit.updateAmount(value);
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
                              return value;
                            },
                            onChanged: (value) {
                              if (value == null) return;
                              cubit.updateAmc(value);
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              // ~ Type ~
                              Expanded(
                                child: AsyncFormField<TransactionType>(
                                  contentAlignment: Alignment.center,
                                  initialValue: cubit.state.type,
                                  validator: (value) {
                                    if (value == null) {
                                      return 'Can\'t be empty';
                                    }
                                    return null;
                                  },
                                  onTapCallback: () {
                                    int index = _types.indexOf(cubit.state.type);
                                    if (index < 0) {
                                      index = 0;
                                    }
                                    final nextIndex = index < (_types.length - 1) ? index + 1 : 0;
                                    return _types.elementAt(nextIndex);
                                  },
                                  onChanged: (value) {
                                    if (value == null) return;
                                    cubit.updateTransactionType(value);
                                  },
                                  childBuilder: (value) {
                                    if (value == null) {
                                      return const Text(
                                        'Select type',
                                        style: TextStyle(color: Colors.grey),
                                        overflow: TextOverflow.ellipsis,
                                      );
                                    }

                                    return _TransactionTypeViewer(type: value);
                                  },
                                ).withLabel('Type'),
                              ),

                              // ~ Date ~
                              Expanded(
                                child: AsyncFormField<DateTime>(
                                  initialValue: cubit.state.date,
                                  validator: (value) {
                                    if (value == null) {
                                      return 'Can\'t be empty';
                                    }
                                    return null;
                                  },
                                  onTapCallback: () async {
                                    final value = await showDatePicker(
                                      context: context,
                                      initialDate: cubit.state.date ?? _dateNow,
                                      firstDate: DateTime(1990),
                                      lastDate: _dateNow,
                                    );
                                    if (value == null) return null;
                                    cubit.updateDate(value);
                                    return value;
                                  },
                                  childBuilder: (date) {
                                    if (date == null) {
                                      return const Text('Select date', style: TextStyle(color: Colors.grey));
                                    }
                                    final days = _dateNow.difference(date).inDays;
                                    final label = switch (days) {
                                      0 => 'Today',
                                      1 => 'Yesterday',
                                      _ => date.toReadable(),
                                    };
                                    return Text(label, overflow: TextOverflow.ellipsis);
                                  },
                                ).withLabel('Date'),
                              ),
                            ],
                          ),

                          // ~~~ Note ~~~
                          TextFormField(
                            decoration: const InputDecoration(hintText: 'Notes'),
                            onChanged: (value) => cubit.updateNotes(value),
                            onTapOutside: (_) => minimizeKeyboard(),
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

    return FormField<InveslyAccount>(
      builder: (state) {
        late final Widget icon;

        if (state.hasError) {
          icon = Icon(Icons.person_2_rounded, color: context.colors.error);
        } else if (state.value != null) {
          icon = CircleAvatar(foregroundImage: AssetImage(state.value!.avatar), radius: 20.0);
        } else {
          icon = const Icon(Icons.person_2_rounded);
        }
        return Shake(
          shake: state.hasError,
          child: IconButton(
            onPressed: () async {
              final newUser = await InveslyAccountPickerWidget.showModal(context, cubit.state.userId);
              if (newUser == null) return;

              cubit.updateUser(newUser.id);
              state.didChange(newUser);
            },
            style: IconButton.styleFrom(
              backgroundColor: state.hasError ? context.colors.errorContainer : context.colors.primaryContainer,
            ),
            icon: icon,
            // icon: BlocBuilder<UsersCubit, UsersState>(
            //   builder: (context, state) {
            //     if (state is UsersErrorState) {
            //       return const Icon(Icons.error_outline_rounded, color: Colors.redAccent);
            //     }

            //     if (state is UsersLoadedState) {
            //       final users = state.users;
            //       final currentUser = users.isEmpty ? null : users.firstWhereOrNull((u) => u.id == cubit.state.userId);

            //       return CircleAvatar(
            //         foregroundImage: currentUser != null ? AssetImage(currentUser.avatar) : null,
            //         radius: 20.0,
            //         child: Text(currentUser?.name.substring(0, 1).toUpperCase() ?? '?'),
            //       );
            //     }

            //     return const CircularProgressIndicator();
            //   },
            // ),
          ),
        );
      },
      validator: (value) {
        if (value == null) {
          return 'Please select a user';
        }
        return null;
      },
    );
  }
}

class _TransactionTypeViewer extends StatefulWidget {
  const _TransactionTypeViewer({super.key, required this.type});

  final TransactionType type;

  @override
  State<_TransactionTypeViewer> createState() => __TransactionTypeViewerState();
}

class __TransactionTypeViewerState extends State<_TransactionTypeViewer> {
  late TransactionType _prevType;
  // AnimationController? _fadeOutController;
  AnimationController? _fadeInController;

  @override
  void initState() {
    super.initState();
    _prevType = widget.type;
    // _fadeOutController?.value = 1.0;
    // _fadeInController?.value = 1.0;
  }

  @override
  void didUpdateWidget(_TransactionTypeViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    _prevType = oldWidget.type;
    if (_prevType != widget.type) {
      // _fadeOutController
      //   ?..reset()
      //   ..forward();
      _fadeInController
        ?..reset()
        ..forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        // FadeOut(
        //   fadeOut: false,
        //   to: Offset(0.0, -0.4),
        //   controller: (ctrl) => _fadeOutController = ctrl,
        //   child: Text(_prevType.name.toSentenceCase()),
        // ),
        FadeIn(
          // fadeIn: false,
          from: Offset(0.0, 0.4),
          controller: (ctrl) => _fadeInController = ctrl,
          child: Text(widget.type.name.toUpperCase()),
        ),
      ],
    );
  }
}
