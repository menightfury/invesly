import 'dart:async';

import 'package:intl/intl.dart';
import 'package:invesly/accounts/cubit/accounts_cubit.dart';
import 'package:invesly/accounts/view/edit_account/edit_account_page.dart';

import 'package:invesly/amcs/model/amc_model.dart';
import 'package:invesly/amcs/view/widgets/amc_picker_widget.dart';
import 'package:invesly/common/cubit/app_cubit.dart';
import 'package:invesly/common/extensions/color_extension.dart';
import 'package:invesly/common/extensions/widget_extension.dart';
import 'package:invesly/common/presentations/animations/fade_in.dart';
import 'package:invesly/common/presentations/animations/shake.dart';
import 'package:invesly/common/presentations/widgets/popups.dart';
import 'package:invesly/common/presentations/widgets/rolling_through_options.dart';
import 'package:invesly/common/presentations/widgets/simple_card.dart';
import 'package:invesly/common/utils/keyboard.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/dashboard/view/dashboard_page.dart';
import 'package:invesly/transactions/edit_transaction/widgets/calculator/calculator.dart';
import 'package:invesly/transactions/model/transaction_model.dart';
import 'package:invesly/transactions/model/transaction_repository.dart';

import 'cubit/edit_transaction_cubit.dart';

class EditTransactionPage extends StatelessWidget {
  const EditTransactionPage({super.key, this.initialTransaction, this.initialAccountId, this.initialAmc});

  final InveslyTransaction? initialTransaction;
  final int? initialAccountId;
  final InveslyAmc? initialAmc;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        return EditTransactionCubit(
          repository: TransactionRepository.instance,
          initialTransaction: initialTransaction,
          initialAccountId: initialAccountId,
          initialAmc: initialAmc,
        );
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
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<EditTransactionCubit>();
    // final genres = AmcGenre.values;
    final types = TransactionType.values;

    $logger.i('Rebuilding edit transaction screen');

    return BlocListener<EditTransactionCubit, EditTransactionState>(
      listenWhen: (prev, curr) => (prev.status != curr.status && curr.isFailureOrSuccess),
      listener: (context, state) async {
        late final SnackBar message;
        if (state.status == EditTransactionStatus.saved) {
          message = const SnackBar(content: Text('Investment saved successfully'), backgroundColor: Colors.teal);
          context.canPop ? Navigator.pop(context) : context.go(const DashboardPage());
        } else if (state.status == EditTransactionStatus.failed) {
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
                  snap: true,
                  floating: true,
                  title: Text('${cubit.state.isNewTransaction ? 'Add' : 'Edit'} Investment'),
                  // actions: <Widget>[_AccountPickerWidget()],
                  // actionsPadding: const EdgeInsets.only(right: 16.0),
                ),

                // // ~ Title
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
                //   child: Column(
                //     mainAxisSize: MainAxisSize.min,
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: <Widget>[
                //       Text(cubit.state.isNewTransaction ? 'Add' : 'Edit', style: context.textTheme.headlineSmall),
                //       Text('Investment', style: context.textTheme.headlineMedium),
                //     ],
                //   ),
                // ),

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
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _AmcPicker().withLabel('Asset management company (AMC)'),
                  ),
                ),

                const SliverGap(12.0),

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

                // ~ Account picker
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _AccountPickerWidget().withLabel('Account'),
                  ),
                ),

                const SliverGap(12.0),

                // ~~~ Type and Date ~~~
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
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
                                color: context.theme.inputDecorationTheme.fillColor,
                              );
                            },
                          ).withLabel('Transaction type'),
                        ),

                        // ~ Date ~
                        Expanded(child: _DatePicker().withLabel('Date')),
                      ],
                    ),
                  ),
                ),

                const SliverGap(12.0),

                // ~~~ Units and Amount ~~~
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: BlocSelector<EditTransactionCubit, EditTransactionState, bool>(
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
                                    // ~ Rate (Unit price)
                                    Expanded(
                                      child: Column(
                                        spacing: iFormFieldLabelSpacing,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          // ~ Label
                                          BlocSelector<EditTransactionCubit, EditTransactionState, AmcGenre?>(
                                            selector: (state) => state.amc?.genre,
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
                                          // ~ Rate field
                                          BlocBuilder<EditTransactionCubit, EditTransactionState>(
                                            buildWhen: (prev, curr) {
                                              return prev.rate != curr.rate ||
                                                  prev.rateError != curr.rateError ||
                                                  (prev.status != curr.status &&
                                                      curr.isError &&
                                                      curr.rateError != null);
                                            },
                                            builder: (context, state) {
                                              $logger.i('Rate is Rebuilding');
                                              return _FormField(
                                                onTap: () async {
                                                  final newRate = await InveslyCalculatorWidget.showModal(
                                                    context,
                                                    state.rate,
                                                  );
                                                  if (newRate == null) return;
                                                  cubit.updateRate(newRate.toDouble());
                                                },
                                                errorText: state.rateError,
                                                contentAlignment: AlignmentGeometry.centerRight,
                                                child: Text(
                                                  state.rate == null
                                                      ? 'e.g. 1,500'
                                                      : NumberFormat.decimalPattern('en_IN').format(state.rate),
                                                  style: state.rate == null ? TextStyle(color: Colors.grey) : null,
                                                  textAlign: TextAlign.right,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),

                                    // ~ No. of Units (Quantity)
                                    Expanded(
                                      child: Column(
                                        spacing: iFormFieldLabelSpacing,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          // ~ Label
                                          BlocSelector<EditTransactionCubit, EditTransactionState, AmcGenre?>(
                                            selector: (state) => state.amc?.genre,
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
                                          // ~ Quantity field
                                          BlocBuilder<EditTransactionCubit, EditTransactionState>(
                                            buildWhen: (prev, curr) {
                                              return prev.qnty != curr.qnty ||
                                                  prev.qntyError != curr.qntyError ||
                                                  (prev.status != curr.status &&
                                                      curr.isError &&
                                                      curr.qntyError != null);
                                            },
                                            builder: (context, state) {
                                              $logger.i('Quantity is Rebuilding');
                                              return _FormField(
                                                onTap: () async {
                                                  final newQnty = await InveslyCalculatorWidget.showModal(
                                                    context,
                                                    state.qnty,
                                                  );
                                                  if (newQnty == null) return;
                                                  cubit.updateQuantity(newQnty.toDouble());
                                                },
                                                errorText: state.qntyError,
                                                contentAlignment: AlignmentGeometry.centerRight,
                                                child: Text(
                                                  state.qnty == null
                                                      ? 'e.g. 15'
                                                      : NumberFormat.decimalPattern('en_IN').format(state.qnty),
                                                  style: state.qnty == null ? TextStyle(color: Colors.grey) : null,
                                                  textAlign: TextAlign.right,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
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
                  ),
                ),

                const SliverGap(16.0),

                // ~~~ Total amount ~~~
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      spacing: iFormFieldLabelSpacing,
                      crossAxisAlignment: CrossAxisAlignment.start, // CrossAxisAlignment.stretch
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              const Text('Total amount', overflow: TextOverflow.ellipsis),

                              // ~ Auto calculate
                              BlocSelector<EditTransactionCubit, EditTransactionState, bool>(
                                selector: (state) => [AmcGenre.insurance, AmcGenre.misc].contains(state.amc?.genre),
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

                        // ~ Total amount field
                        BlocBuilder<EditTransactionCubit, EditTransactionState>(
                          buildWhen: (prev, curr) {
                            return prev.totalAmount != curr.totalAmount ||
                                prev.totalAmountError != curr.totalAmountError ||
                                (prev.status != curr.status && curr.isError && curr.totalAmountError != null) ||
                                prev.canEditAmount != curr.canEditAmount;
                          },
                          builder: (context, state) {
                            $logger.i('Total amount section is Rebuilding');
                            return _FormField(
                              enabled: state.canEditAmount,
                              onTap: () async {
                                final newAmount = await InveslyCalculatorWidget.showModal(context, state.totalAmount);
                                if (newAmount == null) return;
                                cubit.updateAmount(newAmount.toDouble());
                              },
                              errorText: state.totalAmountError,
                              contentAlignment: AlignmentGeometry.centerRight,
                              child: Text(
                                state.totalAmount == null
                                    ? 'e.g. 1,500'
                                    : NumberFormat.decimalPattern('en_IN').format(state.totalAmount),
                                style: state.totalAmount == null ? TextStyle(color: Colors.grey) : null,
                                textAlign: TextAlign.right,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverGap(16.0),

                // ~~~ Note ~~~
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextField(
                      maxLines: 3,
                      decoration: const InputDecoration(hintText: 'Notes'),
                      onChanged: cubit.updateNotes,
                      onTapOutside: (_) => minimizeKeyboard(),
                    ).withLabel('Note'),
                  ),
                ),

                const SliverGap(16.0),
              ],
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

  Future<void> _handleSavePressed(BuildContext context) async {
    final transactionCubit = context.read<EditTransactionCubit>();
    await transactionCubit.save();
  }
}

class _AccountPickerWidget extends StatefulWidget {
  const _AccountPickerWidget({super.key});

  @override
  State<_AccountPickerWidget> createState() => _AccountPickerWidgetState();
}

class _AccountPickerWidgetState extends State<_AccountPickerWidget> {
  @override
  void initState() {
    super.initState();
    // Fetch accounts, if not already fetched
    final cubit = context.read<AccountsCubit>();
    if (!cubit.state.isLoaded) {
      cubit.fetchAccounts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<EditTransactionCubit>();
    const cardPadding = EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0);

    return BlocBuilder<AccountsCubit, AccountsState>(
      builder: (context, accountsState) {
        // ~ Error state
        if (accountsState.isError) {
          return SimpleCard(
            label: Text('Failed to load accounts', style: TextStyle(color: context.colors.error)),
            padding: cardPadding,
            color: context.colors.errorContainer,
          );
        }

        // ~ Loaded state
        if (accountsState is AccountsLoadedState) {
          final accounts = accountsState.accounts;
          return BlocBuilder<EditTransactionCubit, EditTransactionState>(
            buildWhen: (prev, curr) {
              return prev.accountId != curr.accountId ||
                  prev.accountError != curr.accountError ||
                  (prev.status != curr.status && curr.isError && curr.accountError != null);
            },
            builder: (context, editTrnState) {
              final isError = editTrnState.accountError != null;
              // final account = state.accountId != null && accounts.isNotEmpty
              //     ? accounts.firstWhereOrNull((a) => a.id == state.accountId)
              //     : null;

              $logger.i('Account Picker Rebuilding');
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,

                clipBehavior: Clip.none,
                child: Row(
                  spacing: 8.0,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    // ~~~ Accounts ~~~
                    if (accounts.isNotEmpty)
                      ...accounts.map((account) {
                        final isSelected = account.id == editTrnState.accountId;
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            GestureDetector(
                              onTap: () => cubit.updateAccount(account.id),
                              behavior: HitTestBehavior.opaque,
                              child: SimpleCard(
                                padding: cardPadding,
                                shape: RoundedRectangleBorder(
                                  borderRadius: iCardBorderRadius,
                                  side: isSelected
                                      ? BorderSide(width: 2.0, color: context.colors.primary)
                                      : BorderSide.none,
                                ),
                                elevation: isSelected ? 2.0 : 0.0,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  spacing: 12.0,
                                  children: <Widget>[
                                    account.icon.buildWidget(
                                      context,
                                      backgroundColor: account.color?.withAlpha(0x33),
                                      color: account.color,
                                    ),
                                    Text(
                                      account.name,
                                      overflow: TextOverflow.ellipsis,
                                      style: context.textTheme.headlineSmall?.copyWith(
                                        color: isSelected ? context.colors.primary : null,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            if (isError)
                              Padding(
                                padding: cardPadding.copyWith(top: 4.0, bottom: 0.0),
                                child: FadeIn(
                                  from: Offset(0.0, -0.25),
                                  child: DefaultTextStyle(
                                    style: context.textTheme.bodySmall!
                                        .copyWith(color: context.colors.error)
                                        .merge(context.theme.inputDecorationTheme.errorStyle),
                                    child: Text(
                                      editTrnState.accountError!,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      }),

                    // ~~~ Add account ~~~
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => context.push(const EditAccountPage()),
                      child: SimpleCard(
                        padding: cardPadding,
                        shape: RoundedRectangleBorder(
                          borderRadius: iCardBorderRadius,
                          side: BorderSide(width: 2.0, color: context.theme.disabledColor.lighten(80)),
                        ),
                        color: context.colors.surface,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          spacing: 12.0,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SizedBox.square(
                              dimension: 40.0,
                              child: PhysicalModel(
                                color: context.theme.disabledColor.lighten(50),
                                shape: BoxShape.circle,
                                child: SizedBox.square(
                                  dimension: 40.0,
                                  child: Icon(Icons.add_rounded, color: Colors.white),
                                ),
                              ),
                            ),
                            Text(
                              'Add account',
                              overflow: TextOverflow.ellipsis,
                              style: context.textTheme.bodyMedium?.copyWith(color: context.theme.disabledColor),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );

              // return Shake(
              //   shake: isError,
              //   child: AccountPickerWidget(
              //     accountId: state.accountId,
              //     onPickup: (value) => cubit.updateAccount(value.id),
              //     side: BorderSide.none,
              //     color: context.theme.inputDecorationTheme.fillColor,
              //     avatar: account != null
              //         ? account.buildIconWidget(
              //             size: 28.0,
              //             backgroundColor: account.color.withAlpha(0x33),
              //             foregroundColor: account.color,
              //             iconSize: 18.0,
              //           )
              //         : Icon(Icons.supervised_user_circle_rounded, size: 22.0, color: Colors.grey),
              //     child: Text(
              //       account?.name ?? state.accountId?.toString() ?? 'Select account',
              //       style: TextStyle(color: state.accountId == null ? Colors.grey : null),
              //     ),
              //   ),
              // );
            },
          );
        }

        return Skeletonizer(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 8.0,
            children: List.generate(2, (_) {
              return const Skeleton.leaf(
                child: SimpleCard(label: Text('Loading accounts...'), padding: cardPadding),
              );
            }),
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
    final cubit = context.read<EditTransactionCubit>();

    return BlocBuilder<EditTransactionCubit, EditTransactionState>(
      buildWhen: (prev, curr) {
        return prev.amc != curr.amc ||
            prev.amcError != curr.amcError ||
            (prev.status != curr.status && curr.isError && curr.amcError != null);
      },
      builder: (context, state) {
        $logger.i('AMC Picker Rebuilding');
        return _FormField(
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
          errorText: state.amcError,
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
    final dateNow = DateTime.now();
    final cubit = context.read<EditTransactionCubit>();

    return BlocBuilder<EditTransactionCubit, EditTransactionState>(
      buildWhen: (prev, curr) {
        return prev.date != curr.date ||
            prev.dateError != curr.dateError ||
            (prev.status != curr.status && curr.isError && curr.dateError != null);
      },
      builder: (context, state) {
        $logger.i('Date Picker Rebuilding');
        return _FormField(
          onTap: () async {
            final newDate = await showDatePicker(
              context: context,
              initialDate: state.date ?? dateNow,
              firstDate: DateTime(1990),
              lastDate: dateNow,
            );
            if (newDate == null) return;
            cubit.updateDate(newDate.startOfDay);
          },
          leading: const Icon(Icons.edit_calendar_rounded),
          errorText: state.dateError,
          child: _buildChild(context, state.date),
        );
      },
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
    super.key,
    this.enabled = true,
    this.onTap,
    required this.child,
    this.leading,
    this.trailing,
    this.errorText,
    this.errorBuilder,
    this.padding = iFormFieldContentPadding,
    this.contentAlignment = Alignment.centerLeft,
    this.color,
  });

  final bool enabled;
  final VoidCallback? onTap;
  final Widget child;
  final Widget? leading;
  final Widget? trailing;
  final String? errorText;
  final Widget Function(BuildContext, String)? errorBuilder;
  final EdgeInsets padding;
  final AlignmentGeometry contentAlignment;
  final WidgetStateColor? color;

  bool get hasError => errorText != null;

  Set<WidgetState> get widgetState => <WidgetState>{
    if (!enabled) WidgetState.disabled,
    if (hasError) WidgetState.error,
  };

  @override
  Widget build(BuildContext context) {
    // final defaultColor = WidgetStateColor.resolveWith((Set<WidgetState> states) {
    //   if (states.contains(WidgetState.disabled)) {
    //     return Colors.black12;
    //   }
    //   if (states.contains(WidgetState.error)) {
    //     return context.colors.errorContainer;
    //   }
    //   return context.colors.secondaryContainer;
    // });
    final defaultColor = InputDecorationTheme.of(context).fillColor ?? context.colors.secondaryContainer;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      // spacing: 4.0,
      children: <Widget>[
        Shake(
          shake: hasError,
          child: Tappable(
            onTap: enabled ? onTap : null,
            childAlignment: contentAlignment,
            padding: padding,
            leading: leading,
            trailing: trailing,
            color: color?.resolve(widgetState) ?? WidgetStateProperty.resolveAs<Color>(defaultColor, widgetState),
            child: child,
          ),
        ),

        if (hasError)
          Padding(
            padding: padding.copyWith(top: 4.0, bottom: 0.0),
            child: FadeIn(
              from: Offset(0.0, -0.25),
              child: DefaultTextStyle(
                style: context.textTheme.bodySmall!
                    .copyWith(color: context.colors.error)
                    .merge(context.theme.inputDecorationTheme.errorStyle),
                child:
                    errorBuilder?.call(context, errorText!) ??
                    Text(errorText!, overflow: TextOverflow.ellipsis, maxLines: 1),
              ),
            ),
          ),
      ],
    );
  }
}
