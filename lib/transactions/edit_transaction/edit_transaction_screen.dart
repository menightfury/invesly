import 'dart:async';

import 'package:intl/intl.dart';

import 'package:invesly/accounts/cubit/accounts_cubit.dart';
import 'package:invesly/accounts/model/account_model.dart';
import 'package:invesly/accounts/widget/account_picker_widget.dart';
import 'package:invesly/amcs/model/amc_model.dart';
import 'package:invesly/amcs/view/widgets/amc_picker_widget.dart';
import 'package:invesly/common/cubit/app_cubit.dart';
import 'package:invesly/common/extensions/widget_extension.dart';
import 'package:invesly/common/presentations/animations/fade_in.dart';
import 'package:invesly/common/presentations/animations/shake.dart';
import 'package:invesly/common/presentations/widgets/async_form_field.dart';
import 'package:invesly/common/presentations/widgets/popups.dart';
import 'package:invesly/common/utils/keyboard.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/dashboard/view/dashboard_screen.dart';
import 'package:invesly/transactions/edit_transaction/widgets/calculator/calculator.dart';
import 'package:invesly/transactions/model/transaction_model.dart';
import 'package:invesly/transactions/model/transaction_repository.dart';
import 'package:invesly/transactions/widgets/genre_selector_form_field.dart';

import 'cubit/edit_transaction_cubit.dart';

class EditTransactionScreen extends StatelessWidget {
  const EditTransactionScreen({super.key, this.initialTransaction});

  final InveslyTransaction? initialTransaction;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        return EditTransactionCubit(repository: context.read<TransactionRepository>(), initial: initialTransaction);
      },
      child: const _EditTransactionScreen(),
    );
  }
}

class _EditTransactionScreen extends StatefulWidget {
  const _EditTransactionScreen({super.key});

  @override
  State<_EditTransactionScreen> createState() => __EditTransactionScreenState();
}

class __EditTransactionScreenState extends State<_EditTransactionScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final DateTime _dateNow;

  @override
  void initState() {
    super.initState();
    _dateNow = DateTime.now();
  }

  @override
  void dispose() {
    _formKey.currentState?.reset();
    super.dispose();
  }

  Future<void> _handleSavePressed(BuildContext context) async {
    final transactionCubit = context.read<EditTransactionCubit>();
    // final amcRepository = context.read<AmcRepository>();
    if (_formKey.currentState!.validate()) {
      await transactionCubit.save();
      // if (!context.mounted) return;
      // const message = SnackBar(content: Text('Investment saved successfully.'), backgroundColor: Colors.teal);
      // ScaffoldMessenger.of(context).showSnackBar(message);
      // Navigator.maybePop<bool>(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<EditTransactionCubit>();

    return BlocListener<EditTransactionCubit, EditTransactionState>(
      listenWhen: (prev, curr) {
        return (prev.status != curr.status && curr.isFailureOrSuccess) ||
            (prev.isPopping != curr.isPopping && curr.isPopping);
      },
      listener: (context, state) async {
        if (state.isPopping) {
          if (state.status == EditTransactionStatus.edited) {
            final canPop = await showDiscardChangesDialog(context) ?? false;
            if (canPop && context.mounted) {
              Navigator.of(context).pop();
            } else {
              cubit.requestPop(false);
            }
          } else {
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          }
        } else {
          late final SnackBar message;
          if (state.status == EditTransactionStatus.saved) {
            if (context.canPop) {
              Navigator.of(context).pop();
            } else {
              // context.go(AppRouter.dashboard);
              context.go(const DashboardScreen());
            }
            message = const SnackBar(content: Text('Investment saved successfully'), backgroundColor: Colors.teal);
          } else if (state.status == EditTransactionStatus.failed) {
            message = const SnackBar(content: Text('Sorry! some error occurred'), backgroundColor: Colors.redAccent);
          }
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(message);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Form(
            canPop: false, // prevents default
            onPopInvokedWithResult: (didPop, _) {
              if (didPop) return;
              cubit.requestPop(true);
            },
            key: _formKey,
            autovalidateMode: AutovalidateMode.disabled,
            child: CustomScrollView(
              slivers: <Widget>[
                SliverAppBar(
                  pinned: true,
                  floating: true,
                  actions: [_AccountPickerWidget()],
                  actionsPadding: const EdgeInsets.only(right: 16.0),
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
                          Text(cubit.state.isNewTransaction ? 'Add' : 'Edit', style: context.textTheme.headlineSmall),
                          Text('Investment', style: context.textTheme.headlineMedium),
                        ],
                      ),
                    ),
                    const Gap(12.0),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        spacing: 12.0,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ~~~ Genre and Date ~~~
                          Row(
                            spacing: 12.0,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              // ~ Genre ~
                              Expanded(
                                child: GenreSelectorFormField(
                                  initialValue: cubit.state.genre,
                                  onChanged: (value) {
                                    if (value == null) return;
                                    cubit.updateGenre(value);
                                  },
                                ).withLabel('Investment type'),
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
                                  onTapCallback: (value) async {
                                    final newDate = await showDatePicker(
                                      context: context,
                                      initialDate: value ?? _dateNow,
                                      firstDate: DateTime(1990),
                                      lastDate: _dateNow,
                                    );
                                    if (newDate == null) return null;
                                    cubit.updateDate(newDate);
                                    return newDate;
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

                          // ~~~ AMC ~~~
                          AsyncFormField<InveslyAmc>(
                            initialValue: cubit.state.amc,
                            validator: (value) {
                              if (value == null) {
                                return 'Can\'t be empty';
                              }
                              return null;
                            },
                            onTapCallback: (value) async {
                              // final newAmc = await InveslyAmcPickerWidget.showModal(context, value?.id);
                              final newAmc = await context.push<InveslyAmc>(
                                InveslyAmcPickerWidget(
                                  amcId: value?.id,
                                  genre: cubit.state.genre,
                                  onPickup: (amc) => context.pop(amc),
                                ),
                              );
                              return newAmc ?? value;
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

                          // ~~~ Units and Amount ~~~
                          BlocSelector<EditTransactionCubit, EditTransactionState, bool>(
                            selector: (state) => state.canEditRateAndQnty,
                            builder: (context, isVisible) {
                              return AnimatedSize(
                                alignment: Alignment.topCenter,
                                duration: 250.ms,
                                curve: Curves.easeInOut,
                                child: isVisible
                                    ? Row(
                                        spacing: 12.0,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          // ~ Rate or Unit price
                                          Expanded(
                                            child: Column(
                                              spacing: iFormFieldLabelSpacing,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start, // CrossAxisAlignment.stretch
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                BlocSelector<EditTransactionCubit, EditTransactionState, AmcGenre>(
                                                  selector: (state) => state.genre,
                                                  builder: (context, genre) {
                                                    final label = switch (genre) {
                                                      AmcGenre.mf => 'NAV (Rs.)',
                                                      _ => 'Unit price (Rs.)',
                                                    };
                                                    return Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                                      child: FadeIn(
                                                        key: ValueKey(label),
                                                        from: Offset(0.0, 0.4),
                                                        child: Text(label, overflow: TextOverflow.ellipsis),
                                                      ),
                                                    );
                                                  },
                                                ),
                                                BlocSelector<EditTransactionCubit, EditTransactionState, bool>(
                                                  selector: (state) =>
                                                      [AmcGenre.insurance, AmcGenre.misc].contains(state.genre),
                                                  builder: (context, disabled) {
                                                    return AsyncFormField<num>(
                                                      initialValue: cubit.state.rate,
                                                      enabled: !disabled,
                                                      validator: (value) {
                                                        if (value == null || value.isNegative) {
                                                          return 'Can\'t be empty or negative';
                                                        }
                                                        return null;
                                                      },
                                                      onTapCallback: (value) async {
                                                        final newValue = await InveslyCalculatorWidget.showModal(
                                                          context,
                                                          value,
                                                        );
                                                        return newValue ?? value;
                                                      },
                                                      onChanged: (value) {
                                                        if (value == null) return;
                                                        cubit.updateRate(value.toDouble());
                                                      },
                                                      childBuilder: (value) {
                                                        if (value == null) {
                                                          return const Text(
                                                            'e.g. 1,500',
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
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),

                                          // ~ No. of Units
                                          Expanded(
                                            child: Column(
                                              spacing: iFormFieldLabelSpacing,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start, // CrossAxisAlignment.stretch
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                BlocSelector<EditTransactionCubit, EditTransactionState, AmcGenre>(
                                                  selector: (state) => state.genre,
                                                  builder: (context, genre) {
                                                    final label = switch (genre) {
                                                      AmcGenre.stock => 'No. of shares',
                                                      _ => 'No. of units',
                                                    };
                                                    return Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                                      child: FadeIn(
                                                        key: ValueKey(label),
                                                        from: Offset(0.0, 0.4),
                                                        child: Text(label, overflow: TextOverflow.ellipsis),
                                                      ),
                                                    );
                                                  },
                                                ),
                                                BlocSelector<EditTransactionCubit, EditTransactionState, bool>(
                                                  selector: (state) =>
                                                      [AmcGenre.insurance, AmcGenre.misc].contains(state.genre),
                                                  builder: (context, disabled) {
                                                    return AsyncFormField<num>(
                                                      initialValue: cubit.state.quantity,
                                                      enabled: !disabled,
                                                      validator: (value) {
                                                        // if (value == null) {
                                                        //   return 'Can\'t be empty';
                                                        // }
                                                        if (value?.isNegative ?? false) {
                                                          return 'Can\'t be negative';
                                                        }
                                                        return null;
                                                      },
                                                      onTapCallback: (value) async {
                                                        final newValue = await InveslyCalculatorWidget.showModal(
                                                          context,
                                                          value,
                                                        );
                                                        return newValue ?? value;
                                                      },
                                                      onChanged: (value) {
                                                        if (value == null) return;
                                                        cubit.updateQuantity(value.toDouble());
                                                      },
                                                      childBuilder: (value) {
                                                        if (value == null) {
                                                          return const Text(
                                                            'e.g. 10',
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
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      )
                                    : SizedBox(width: double.infinity),
                              );
                            },
                          ),

                          // ~~~ Total amount ~~~
                          Column(
                            spacing: iFormFieldLabelSpacing,
                            crossAxisAlignment: CrossAxisAlignment.start, // CrossAxisAlignment.stretch
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    const Text('Total amount (Rs.)', overflow: TextOverflow.ellipsis),
                                    BlocSelector<EditTransactionCubit, EditTransactionState, bool>(
                                      selector: (state) => [AmcGenre.insurance, AmcGenre.misc].contains(state.genre),
                                      builder: (context, disabled) {
                                        if (disabled) {
                                          return SizedBox.shrink();
                                        }
                                        return FadeIn(
                                          from: Offset(0.0, 0.4),
                                          child: BlocSelector<EditTransactionCubit, EditTransactionState, bool>(
                                            selector: (state) => state.autoAmount,
                                            builder: (context, autoAmount) {
                                              return Row(
                                                children: <Widget>[
                                                  Text('Auto', style: context.textTheme.labelSmall),
                                                  SizedBox(
                                                    height: 20.0,
                                                    child: FittedBox(
                                                      fit: BoxFit.fill,
                                                      child: Switch(
                                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                        value: autoAmount,
                                                        onChanged: disabled
                                                            ? null
                                                            : (value) => cubit.updateAutoAmount(value),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              BlocBuilder<EditTransactionCubit, EditTransactionState>(
                                buildWhen: (prev, curr) {
                                  return prev.canEditAmount != curr.canEditAmount ||
                                      prev.rate != curr.rate ||
                                      prev.quantity != curr.quantity;
                                },
                                builder: (context, state) {
                                  return AsyncFormField<num>(
                                    key: ValueKey(state.canEditAmount),
                                    initialValue: state.amount,
                                    enabled: state.canEditAmount,
                                    validator: (value) {
                                      if (value == null || value == 0) {
                                        return 'Can\'t be empty or zero';
                                      }
                                      if (value.isNegative) {
                                        return 'Can\'t be negative';
                                      }
                                      return null;
                                    },
                                    onTapCallback: (value) async {
                                      final newValue = await InveslyCalculatorWidget.showModal(context, value);
                                      return newValue ?? value;
                                    },
                                    onChanged: (value) {
                                      if (value == null) return;
                                      cubit.updateAmount(value.toDouble());
                                    },
                                    childBuilder: (value) {
                                      if (value == null) {
                                        return const Text(
                                          'e.g. 10',
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
                                  );
                                },
                              ),
                            ],
                          ),

                          // ~~~ Note ~~~
                          TextFormField(
                            maxLines: 3,
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

class _AccountPickerWidget extends StatefulWidget {
  const _AccountPickerWidget({super.key});

  @override
  State<_AccountPickerWidget> createState() => _AccountPickerWidgetState();
}

class _AccountPickerWidgetState extends State<_AccountPickerWidget> {
  InveslyAccount? initialAccount;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<EditTransactionCubit>();
    final accountsState = context.read<AccountsCubit>().state;
    if (accountsState.isLoaded) {
      final accounts = (accountsState as AccountsLoadedState).accounts;
      if (accounts.isEmpty) return;

      final currentAccountId = cubit.state.account ?? context.read<AppCubit>().state.primaryAccountId;

      if (cubit.state.isNewTransaction) {
        initialAccount = accounts.firstWhere((acc) => acc.id == currentAccountId, orElse: () => accounts.first);
        cubit.updateAccount(initialAccount!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<EditTransactionCubit>();

    return FormField<InveslyAccount>(
      initialValue: initialAccount,
      builder: (formFieldState) {
        return Shake(
          shake: formFieldState.hasError,
          child: GestureDetector(
            onTap: () async {
              final newUser = await InveslyAccountPickerWidget.showModal(context, cubit.state.account?.id);
              if (newUser == null) return;

              cubit.updateAccount(newUser);
              formFieldState.didChange(newUser);
            },
            child: CircleAvatar(
              foregroundImage: formFieldState.value != null ? AssetImage(formFieldState.value!.avatarSrc) : null,
              backgroundColor: formFieldState.hasError ? context.colors.errorContainer : null,
              child: formFieldState.value == null
                  ? Icon(Icons.person_rounded, color: formFieldState.hasError ? context.colors.error : null)
                  : null,
            ),
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
