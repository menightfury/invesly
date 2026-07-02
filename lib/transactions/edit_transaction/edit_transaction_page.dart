import 'dart:async';

import 'package:intl/intl.dart';
import 'package:invesly/accounts/cubit/accounts_cubit.dart';

import 'package:invesly/accounts/widget/account_picker_widget.dart';
import 'package:invesly/amcs/model/amc_model.dart';
import 'package:invesly/amcs/view/widgets/amc_picker_widget.dart';
import 'package:invesly/common/cubit/app_cubit.dart';
// import 'package:invesly/common/cubit/app_cubit.dart';
import 'package:invesly/common/extensions/widget_extension.dart';
import 'package:invesly/common/presentations/animations/fade_in.dart';
import 'package:invesly/common/presentations/animations/shake.dart';
import 'package:invesly/common/presentations/widgets/async_form_field.dart';
import 'package:invesly/common/presentations/widgets/popups.dart';
import 'package:invesly/common/presentations/widgets/rolling_through_options.dart';
import 'package:invesly/common/utils/keyboard.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/dashboard/view/dashboard_page.dart';
import 'package:invesly/transactions/edit_transaction/widgets/calculator/calculator.dart';
import 'package:invesly/transactions/model/transaction_model.dart';
import 'package:invesly/transactions/model/transaction_repository.dart';

import 'cubit/edit_transaction_cubit.dart';

class EditTransactionPage extends StatelessWidget {
  const EditTransactionPage({super.key, this.initialTransaction});

  final InveslyTransaction? initialTransaction;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        return EditTransactionCubit(repository: TransactionRepository.instance, initial: initialTransaction);
      },
      child: const _EditTransactionPageContent(),
    );
  }
}

class _EditTransactionPageContent extends StatefulWidget {
  const _EditTransactionPageContent({super.key});

  @override
  State<_EditTransactionPageContent> createState() => _EditTransactionPageContentState();
}

class _EditTransactionPageContentState extends State<_EditTransactionPageContent> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _formKey.currentState?.reset();
    super.dispose();
  }

  Future<void> _handleSavePressed(BuildContext context) async {
    final transactionCubit = context.read<EditTransactionCubit>();
    // final amcRepository = context.read<AmcRepository>();
    // if (_formKey.currentState!.validate()) {
    await transactionCubit.save();
    // if (!context.mounted) return;
    // const message = SnackBar(content: Text('Investment saved successfully.'), backgroundColor: Colors.teal);
    // ScaffoldMessenger.of(context).showSnackBar(message);
    // Navigator.maybePop<bool>(context);
    // }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<EditTransactionCubit>();
    // final genres = AmcGenre.values;
    final types = TransactionType.values;

    $logger.i('Rebuilding edit transaction screen');

    return BlocListener<EditTransactionCubit, EditTransactionState>(
      listenWhen: (prev, curr) {
        return (prev.status != curr.status && curr.isFailureOrSuccess);
      },
      listener: (context, state) async {
        late final SnackBar message;
        if (state.status == EditTransactionStatus.saved) {
          message = const SnackBar(content: Text('Investment saved successfully'), backgroundColor: Colors.teal);
          context.canPop ? Navigator.pop(context) : context.go(const DashboardPage());
        } else if (state.status == EditTransactionStatus.error) {
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

          if (cubit.state.status == EditTransactionStatus.edited) {
            final shouldPop = await showDiscardChangesDialog(context) ?? false;
            if (shouldPop && context.mounted) Navigator.pop(context);
          } else {
            if (context.mounted) Navigator.pop(context);
          }
        },
        child: Scaffold(
          body: SafeArea(
            // TODO: Remove Form, because it rebuilds on every child change
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.disabled,
              child: CustomScrollView(
                slivers: <Widget>[
                  SliverAppBar(
                    pinned: true,
                    floating: true,
                    actions: <Widget>[_AccountPickerWidget()],
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
                          children: <Widget>[
                            // // ~ Genre ~
                            // BlocSelector<EditTransactionCubit, EditTransactionState, AmcGenre>(
                            //   selector: (state) => state.genre,
                            //   builder: (context, genre) {
                            //     return RollingThroughOptions<AmcGenre>(
                            //       value: genre,
                            //       options: genres,
                            //       builder: (value) => Text(value.title, overflow: TextOverflow.ellipsis),
                            //       onChanged: (value) {
                            //         cubit.updateGenre(genre);

                            //         // Reset AMC
                            //         cubit.updateAmc(null);
                            //       },
                            //     );
                            //   },
                            // ).withLabel('Genre'),

                            // ~~~ AMC ~~~
                            // Column(
                            //   spacing: iFormFieldLabelSpacing,
                            //   crossAxisAlignment: CrossAxisAlignment.start,
                            //   mainAxisSize: MainAxisSize.min,
                            //   children: <Widget>[
                            //     BlocSelector<EditTransactionCubit, EditTransactionState, AmcGenre>(
                            //       selector: (state) => state.genre,
                            //       builder: (context, genre) {
                            //         final label = switch (genre) {
                            //           AmcGenre.mf => 'Asset management company (AMC)',
                            //           AmcGenre.stock => 'Company',
                            //           AmcGenre.insurance => 'Insurance provider',
                            //           _ => 'Company / Service provider',
                            //         };
                            //         return Padding(
                            //           padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            //           child: FadeIn(
                            //             // key: Key(label),
                            //             from: Offset(0.0, 0.4),
                            //             child: Text(label, overflow: TextOverflow.ellipsis),
                            //           ),
                            //         );
                            //       },
                            //     ),
                            //     _AmcPicker(),
                            //   ],
                            // ),
                            _AmcPicker().withLabel('Asset management company (AMC)'),

                            // ~~~ Type and Date ~~~
                            Row(
                              spacing: 12.0,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                // ~ Transaction type
                                Expanded(
                                  child: BlocSelector<EditTransactionCubit, EditTransactionState, TransactionType>(
                                    selector: (state) => state.type,
                                    builder: (context, type) {
                                      return RollingThroughOptions<TransactionType>(
                                        value: type,
                                        options: types,
                                        builder: (value) => Text(value.title, overflow: TextOverflow.ellipsis),
                                        onChanged: (value) => cubit.updateTransactionType(value),
                                      );
                                    },
                                  ).withLabel('Transaction type'),
                                ),

                                // ~ Date ~
                                Expanded(child: _DatePicker().withLabel('Date')),
                              ],
                            ),

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
                                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                                      return CustomField<num>(
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
                                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                                      return CustomField<num>(
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
                                                    Text('Auto calculate', style: context.textTheme.labelSmall),
                                                    SizedBox(
                                                      height: 20.0,
                                                      child: FittedBox(
                                                        fit: BoxFit.fill,
                                                        child: Switch(
                                                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                          value: autoAmount,
                                                          onChanged: disabled
                                                              ? null
                                                              : (value) => cubit.updateAutoAmountMode(value),
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
                                    return CustomField<num>(
                                      key: ValueKey(state.canEditAmount),
                                      initialValue: state.totalAmount,
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
      ),
    );
  }
}

class _AccountPickerWidget extends StatelessWidget {
  const _AccountPickerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    $logger.i('Account Picker Rebuilding');
    final cubit = context.read<EditTransactionCubit>();

    return BlocBuilder<EditTransactionCubit, EditTransactionState>(
      buildWhen: (prev, curr) => prev.accountId != curr.accountId || prev.status != curr.status,
      // selector: (state) => state.accountId,
      builder: (context, state) {
        final isError = state.status == EditTransactionStatus.error && state.accountId == null;
        final accountsState = context.read<AccountsCubit>().state;
        final accounts = (accountsState is AccountsLoadedState) ? accountsState.accounts : null;
        final account = state.accountId != null && accounts != null && accounts.isNotEmpty
            ? accounts.firstWhereOrNull((a) => a.id == state.accountId)
            : null;

        return Shake(
          shake: isError,
          child: AccountPickerWidget(
            accountId: state.accountId,
            onPickup: (value) => cubit.updateAccount(value.id),
            avatar: PhysicalModel(
              color: isError ? context.colors.errorContainer : context.colors.primaryContainer,
              shape: BoxShape.circle,
              child: account != null
                  ? Image.asset(account.avatarSrc, height: 22.0, width: 22.0)
                  : Icon(Icons.supervised_user_circle_rounded, size: 22.0, color: Colors.grey),
            ),
            side: BorderSide.none,
            color: isError ? context.colors.errorContainer : context.colors.primaryContainer,
            child: Text(
              account?.name ?? state.accountId?.toString() ?? 'Select account',
              style: TextStyle(color: state.accountId == null ? Colors.grey : null),
            ),
          ),
        );
      },
    );
  }
}

class _AmcPicker extends StatelessWidget {
  const _AmcPicker({super.key});

  @override
  Widget build(BuildContext context) {
    $logger.i('AMC Picker Rebuilding');
    final cubit = context.read<EditTransactionCubit>();

    return BlocBuilder<EditTransactionCubit, EditTransactionState>(
      buildWhen: (prev, curr) => prev.amc != curr.amc || prev.status != curr.status,
      builder: (context, state) {
        final isError = state.status == EditTransactionStatus.error && state.amc == null;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Shake(
              shake: isError,
              child: Tappable(
                onTap: () async {
                  final newAmc = await context.push<InveslyAmc>(
                    InveslyAmcPickerWidget(
                      keyword: state.amc?.name,
                      genre: state.amc?.genre,
                      onPickup: (amc) => Navigator.pop(context, amc),
                    ),
                  );
                  if (newAmc == null) return;
                  cubit.updateAmc(newAmc);
                },
                childAlignment: AlignmentGeometry.centerLeft,
                padding: iFormFieldContentPadding,
                // leading: leading,
                trailing: const Icon(Icons.chevron_right_rounded),
                color: isError ? context.colors.errorContainer : null,
                child: state.amc != null
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(state.amc!.name, overflow: TextOverflow.ellipsis),
                          Text(
                            (state.amc!.genre ?? AmcGenre.misc).title,
                            style: context.textTheme.labelSmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      )
                    : const Text('Select AMC', style: TextStyle(color: Colors.grey)),
              ),
            ),

            // ~ Error
            if (isError)
              Padding(
                padding: iFormFieldContentPadding.copyWith(top: 4.0, bottom: 0.0),
                child: FadeIn(
                  from: Offset(0.0, -0.25),
                  child: Text(
                    'Can\'t be empty',
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodySmall?.copyWith(color: context.colors.error),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _DatePicker extends StatelessWidget {
  const _DatePicker({super.key});

  Widget _buildChild(BuildContext context, [DateTime? date]) {
    if (date == null) {
      return const Text(
        'Select date',
        style: TextStyle(color: Colors.grey),
        overflow: TextOverflow.ellipsis,
      );
    }
    final days = DateTime.now().difference(date).inDays;
    final label = switch (days) {
      0 => 'Today',
      1 => 'Yesterday',
      _ => date.toReadable(context.read<AppCubit>().state.dateFormat),
    };
    return Text(label, overflow: TextOverflow.ellipsis);
  }

  @override
  Widget build(BuildContext context) {
    $logger.i('Date Picker Rebuilding');
    final cubit = context.read<EditTransactionCubit>();

    return BlocBuilder<EditTransactionCubit, EditTransactionState>(
      buildWhen: (prev, curr) => prev != curr,
      builder: (context, state) {
        final isError = state.status == EditTransactionStatus.error && state.date == null;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          // spacing: 4.0,
          children: <Widget>[
            Shake(
              shake: isError,
              child: InveslyDatePicker(
                initialDate: state.date,
                // validator: (value) {
                //   if (value == null) {
                //     return 'Can\'t be empty';
                //   }
                //   return null;
                // },
                color: isError ? context.colors.errorContainer : null,
                onPickup: (value) => cubit.updateDate(value),
                child: _buildChild(context, state.date),
              ),
            ),

            // ~ Error
            if (isError)
              Padding(
                padding: iFormFieldContentPadding.copyWith(top: 4.0, bottom: 0.0),
                child: FadeIn(
                  from: Offset(0.0, -0.25),
                  child: Text(
                    'Can\'t be empty',
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodySmall?.copyWith(color: context.colors.error),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class CustomField<T> extends StatefulWidget {
  const CustomField({
    super.key,
    this.forceErrorText,
    this.validator,
    this.errorBuilder,
    this.initialValue,
    this.enabled = true,
    FutureOr<T?> Function(T? value)? onTapCallback,
    this.onChanged,
    required Widget Function(T? value) childBuilder,
    Widget? leading,
    Widget? trailing,
    EdgeInsetsGeometry padding = iFormFieldContentPadding,
    AlignmentGeometry contentAlignment = Alignment.centerLeft,
    WidgetStateColor? color,
  });

  final ValueChanged<T?>? onChanged;
  final FormFieldValidator<T>? validator;
  final String? forceErrorText;
  final FormFieldErrorBuilder? errorBuilder;
  final T? initialValue;
  final bool enabled;

  @override
  State<CustomField<T>> createState() => _CustomFieldState();
}

class _CustomFieldState<T> extends State<CustomField<T>> {
  Set<WidgetState> get widgetState => <WidgetState>{
    if (!_formField.enabled) WidgetState.disabled,
    // if (isFocused) WidgetState.focused,
    // if (isHovering) WidgetState.hovered,
    if (hasError) WidgetState.error,
  };

  Color get defaultColor => WidgetStateColor.resolveWith((Set<WidgetState> states) {
    if (states.contains(WidgetState.disabled)) {
      return Colors.black12;
    }

    if (states.contains(WidgetState.error)) {
      return context.colors.errorContainer;
    }

    return context.colors.primaryContainer;
  });

  @override
  void didChange(T? value) {
    super.didChange(value);
    if (_formField.autovalidateMode != AutovalidateMode.disabled) {
      validate();
    }
    // Call the onChanged callback if provided
    _formField.onChanged?.call(value);
  }

  @override
  void didUpdateWidget(CustomField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      setValue(widget.initialValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = fieldState as _AsyncFormFieldState;
    final theme = Theme.of(state.context);

    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    final errorText = state.errorText;

    TextStyle errorStyle = textTheme.bodySmall ?? const TextStyle();
    errorStyle = errorStyle.copyWith(color: colors.error).merge(theme.inputDecorationTheme.errorStyle);

    Widget? error;
    if (errorText != null) {
      error =
          errorBuilder?.call(state.context, errorText) ??
          Text(errorText, style: errorStyle, overflow: TextOverflow.ellipsis, maxLines: 1);
    }

    //  final hasError = errorText != null && error != null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4.0,
      children: <Widget>[
        Shake(
          shake: state.hasError,
          child: Tappable(
            onTap: enabled
                ? () {
                    if (onTapCallback == null) return;

                    final result = onTapCallback.call(state.value);
                    if (result is Future<T?>) {
                      result.then((value) => state.didChange(value));
                    } else {
                      state.didChange(result);
                    }
                  }
                : null,
            childAlignment: contentAlignment,
            padding: padding,
            leading: leading,
            trailing: trailing,
            color:
                color?.resolve(state.widgetState) ??
                WidgetStateProperty.resolveAs(state.defaultColor, state.widgetState),
            child: childBuilder(state.value),
          ),
        ),

        //  if (hasError)
        Padding(
          padding: padding.resolve(TextDirection.ltr).copyWith(top: 0.0, bottom: 0.0),
          child: FadeIn(from: Offset(0.0, -0.25), enable: state.hasError, child: error ?? SizedBox.shrink()),
        ),
      ],
    );
  }
}
