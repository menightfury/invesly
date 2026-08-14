import 'dart:async';
import 'dart:math' as math;

import 'package:intl/intl.dart';

import 'package:invesly/accounts/cubit/accounts_cubit.dart';
import 'package:invesly/accounts/view/edit_account/edit_account_page.dart';
import 'package:invesly/accounts/view/widgets/account_picker_widget.dart';
import 'package:invesly/amcs/model/amc_model.dart';
import 'package:invesly/amcs/view/widgets/amc_picker_widget.dart';
import 'package:invesly/common/cubit/app_cubit.dart';
import 'package:invesly/common/extensions/color_extension.dart';
import 'package:invesly/common/extensions/widget_extension.dart';
import 'package:invesly/common/presentations/animations/fade_in.dart';
import 'package:invesly/common/presentations/animations/shake.dart';
import 'package:invesly/common/presentations/widgets/calculator.dart';
import 'package:invesly/common/presentations/widgets/popups.dart';
import 'package:invesly/common/presentations/widgets/rolling_through_options.dart';
import 'package:invesly/common/presentations/widgets/simple_card.dart';
import 'package:invesly/common/presentations/widgets/simple_chip.dart';
import 'package:invesly/common/utils/keyboard.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/dashboard/view/dashboard_page.dart';
import 'package:invesly/stat/cubit/stat_cubit.dart';
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
                SliverToBoxAdapter(
                  child: Padding(
                    padding: iPaddingFromScreenEdge,
                    // child: Column(
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
                    //             key: Key(label),
                    //             from: Offset(0.0, 0.4),
                    //             child: Text(label, overflow: TextOverflow.ellipsis),
                    //           ),
                    //         );
                    //       },
                    //     ),
                    //     _AmcPicker(),
                    //   ],
                    // ),
                    child: _AmcPicker().withLabel('Asset management company (AMC)'),
                  ),
                ),

                const SliverGap(iFormFieldsInterSpacing),

                // ~~~ Type and Date ~~~
                SliverToBoxAdapter(
                  child: Padding(
                    padding: iPaddingFromScreenEdge,
                    child: Row(
                      spacing: 12.0,
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // ~ Type
                        Expanded(
                          child: _TappableFocusableField(
                            padding: EdgeInsets.zero,
                            child: BlocSelector<EditTransactionCubit, EditTransactionState, TransactionType>(
                              selector: (state) => state.type,
                              builder: (context, type) {
                                // return InveslyChoiceChips<TransactionType>(
                                //   value: type,
                                //   options: types,
                                //   labelBuilder: (context, value) => Text(value.title, overflow: TextOverflow.ellipsis),
                                //   onChanged: (value) {
                                //     if (value == null) return;
                                //     cubit.updateTransactionType(value);
                                //   },
                                //   extended: true,
                                //   padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                                // );
                                return RollingThroughOptions<TransactionType>(
                                  value: type,
                                  padding: iFormFieldContentPadding,
                                  options: types,
                                  builder: (value) => Text(value.title, overflow: TextOverflow.ellipsis),
                                  onChanged: (value) => cubit.updateTransactionType(value),
                                  trailing: const Icon(Icons.unfold_more_rounded),
                                );
                              },
                            ),
                          ).withLabel('Type'),
                        ),

                        // ~ Date ~
                        Expanded(child: _DatePicker().withLabel('Date')),
                      ],
                    ),
                  ),
                ),

                const SliverGap(iFormFieldsInterSpacing),

                // ~~~ Amount ~~~
                SliverToBoxAdapter(
                  child: Padding(
                    padding: iPaddingFromScreenEdge,
                    child: _TappableFocusableField(
                      minHeight: 2 * iFormFieldMinimumHeight + 4.0,
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          useSafeArea: true,
                          isScrollControlled: true,
                          builder: (context) => BlocProvider.value(value: cubit, child: _AmountPickerWidget()),
                        );
                      },
                      suggestion: Text('Tap to edit amount'),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 4.0,
                            children: <Widget>[
                              CurrencyView(
                                5000,
                                style: context.textTheme.displayLarge,
                                decimalsStyle: context.textTheme.displaySmall,
                                showCurrencySymbol: false,
                              ),

                              Text('20 units @ Rs. 250', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                          SimpleChip(child: Text('INR')),
                        ],
                      ),
                    ).withLabel('Amount'),
                  ),
                ),

                const SliverGap(iFormFieldsInterSpacing),

                // ~ Account picker
                SliverToBoxAdapter(
                  child: Padding(
                    padding: iPaddingFromScreenEdge,
                    child: Column(
                      spacing: iFormFieldLabelSpacing,
                      crossAxisAlignment: CrossAxisAlignment.start, // CrossAxisAlignment.stretch
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 12.0),
                          child: Text('Select account', overflow: TextOverflow.ellipsis),
                        ),
                        _AccountPickerWidget2(),
                      ],
                    ),
                  ),
                ),

                const SliverGap(iFormFieldsInterSpacing),

                // ~~~ Note ~~~
                SliverToBoxAdapter(
                  child: Padding(
                    padding: iPaddingFromScreenEdge,
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

class _AccountPickerWidget extends StatelessWidget {
  const _AccountPickerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<EditTransactionCubit>();

    return BlocBuilder<EditTransactionCubit, EditTransactionState>(
      buildWhen: (prev, curr) {
        return prev.accountId != curr.accountId ||
            prev.accountError != curr.accountError ||
            (prev.status != curr.status && curr.isError && curr.accountError != null);
      },
      builder: (context, state) {
        final isError = state.accountError != null;
        final accountsState = context.read<AccountsCubit>().state;
        final accounts = (accountsState is AccountsLoadedState) ? accountsState.accounts : null;
        final account = state.accountId != null && accounts != null && accounts.isNotEmpty
            ? accounts.firstWhereOrNull((a) => a.id == state.accountId)
            : null;

        $logger.i('Account Picker Rebuilding');
        return LimitedBox(
          maxWidth: 176,
          child: Shake(
            shake: isError,
            child: AccountPickerWidget(
              accountId: state.accountId,
              onPickup: (value) => cubit.updateAccount(value.id),
              side: BorderSide.none,
              color: isError ? context.colors.errorContainer : null,
              avatar: account?.icon.buildWidget(
                context,
                backgroundColor: account.color?.withAlpha(0x33),
                color: account.color,
              ),
              child: Text(
                account?.name ?? state.accountId?.toString() ?? 'Select account',
                style: TextStyle(color: state.accountId == null ? Colors.grey : null),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AccountPickerWidget2 extends StatefulWidget {
  const _AccountPickerWidget2({super.key});

  @override
  State<_AccountPickerWidget2> createState() => _AccountPickerWidget2State();
}

class _AccountPickerWidget2State extends State<_AccountPickerWidget2> {
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

          if (accounts.isEmpty) {
            return Text('No accounts found');
          }

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
                            Icon(
                              Icons.add_rounded,
                              color: Colors.white,
                            ).inContainer(context, color: context.theme.disabledColor.lighten(50)),
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
        late final Widget child;
        late final Widget suggestion;

        if (state.amc != null) {
          final amc = state.amc!;

          child = Row(
            spacing: 8.0,
            children: <Widget>[
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 6.0,
                  children: <Widget>[
                    Text(amc.name, overflow: TextOverflow.ellipsis),
                    SimpleChip(
                      color: context.colors.primary,
                      child: Text(
                        (amc.genre ?? AmcGenre.misc).title,
                        style: TextStyle(color: context.colors.onPrimary),
                      ),
                    ),
                    if (amc.tags?.isNotEmpty ?? false)
                      Wrap(
                        spacing: 4.0,
                        runSpacing: 4.0,
                        children: amc.tags!
                            .map((tag) => SimpleChip(child: Text(tag, style: context.textTheme.labelSmall)))
                            .toList(),
                      ),
                  ],
                ),
              ),

              // ~ AMC reset button
              IconButton(
                onPressed: () => cubit.resetAmc(),
                color: context.theme.disabledColor,
                icon: Icon(Icons.cancel),
              ),
            ],
          );
          suggestion = Padding(
            padding: iFormFieldContentPadding.copyWith(top: 0.0, bottom: 0.0),
            child: Text('Available units / share: 30.475'),
          );
        } else {
          child = Text('Search AMC', style: TextStyle(color: context.theme.disabledColor));

          const chipPadding = EdgeInsetsGeometry.symmetric(horizontal: 16.0, vertical: 10.0);
          suggestion = BlocBuilder<StatCubit, StatState>(
            builder: (context, statState) {
              if (statState.isError) {
                return SizedBox.shrink();
              }

              late final Widget content;

              if (statState.isLoaded && statState.stats.isNotEmpty) {
                final amcs = statState.stats.map((stat) => stat.amc);
                final screenWidth = MediaQuery.sizeOf(context).width;

                // calculate width of first five chips
                double totalWidth = 0;
                for (int i = 0; i < amcs.length && i < 5; i++) {
                  final amc = amcs.elementAt(i);
                  totalWidth += amc.name.length * 6.0 + 32.0; // Approximate width calculation
                }

                content = SingleChildScrollView(
                  padding: iFormFieldContentPadding.copyWith(top: 0, bottom: 0),
                  scrollDirection: Axis.horizontal,
                  child: LimitedBox(
                    maxWidth: math.max(screenWidth, totalWidth),
                    child: Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: List.generate(amcs.length, (index) {
                        final amc = amcs.elementAt(index);
                        return SimpleChip(
                          padding: chipPadding,
                          onTap: () => cubit.updateAmc(amc),
                          color: context.colors.surface,
                          child: Text(amc.name, style: context.textTheme.bodySmall),
                        );
                      }),
                    ),
                  ),
                );
              } else {
                content = Skeletonizer(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 6.0,
                    children: List.generate(2, (_) {
                      return const Skeleton.leaf(
                        child: SimpleChip(padding: chipPadding, child: Text('AMC loading...')),
                      );
                    }).toList(),
                  ),
                );
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8.0,
                children: <Widget>[
                  Padding(
                    padding: iFormFieldContentPadding.copyWith(top: 0.0, bottom: 0.0),
                    child: const Text('Recommended AMCs', style: TextStyle(fontSize: 14.0)),
                  ),
                  content,
                ],
              );
            },
          );
        }

        return _TappableFocusableField(
          onTap: state.amc == null
              ? () async {
                  final newAmc = await context.push<InveslyAmc>(
                    InveslyAmcPickerWidget(
                      keyword: state.amc?.name,
                      genre: state.amc?.genre,
                      onPickup: (amc) => Navigator.pop(context, amc),
                    ),
                  );
                  if (newAmc == null) return;
                  cubit.updateAmc(newAmc);
                }
              : null,
          errorText: state.amcError,
          suggestion: suggestion,
          suggestionPadding: const EdgeInsets.symmetric(vertical: 8.0),
          child: child,
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
        return _TappableFocusableField(
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
          // leading: const Icon(Icons.edit_calendar_rounded),
          errorText: state.dateError,
          child: _buildChild(context, state.date),
        );
      },
    );
  }
}

class _TappableFocusableField extends StatefulWidget {
  const _TappableFocusableField({
    super.key,
    this.enabled = true,
    this.onTap,
    this.focusNode,
    required this.child,
    this.leading,
    this.trailing,
    this.errorText,
    this.errorBuilder,
    this.padding = iFormFieldContentPadding,
    this.minHeight,
    this.borderRadius,
    this.suggestion,
    this.suggestionPadding,
  });

  final bool enabled;
  final VoidCallback? onTap;
  final FocusNode? focusNode;
  final Widget child;
  final Widget? leading;
  final Widget? trailing;
  final String? errorText;
  final Widget Function(BuildContext, String)? errorBuilder;
  final EdgeInsets padding;
  final double? minHeight;
  final BorderRadius? borderRadius;
  final Widget? suggestion;
  final EdgeInsetsGeometry? suggestionPadding;

  @override
  State<_TappableFocusableField> createState() => _TappableFocusableFieldState();
}

class _TappableFocusableFieldState extends State<_TappableFocusableField> {
  late final WidgetStatesController statesController;
  FocusNode? get _focusNode => widget.focusNode;
  // FocusNode get _effectiveFocusNode => widget.focusNode ?? (_focusNode ??= FocusNode());

  bool get hasFocus => _focusNode?.hasFocus ?? false;

  bool get hasError => widget.errorText != null;

  void handleStatesControllerChange() {
    // Force a rebuild to resolve WidgetStateProperty properties
    setState(() {});
  }

  void handleFocusUpdate(bool hasFocus) {
    statesController.update(WidgetState.focused, hasFocus);
  }

  @override
  void initState() {
    super.initState();
    statesController = WidgetStatesController({
      if (!widget.enabled) WidgetState.disabled,
      if (hasError) WidgetState.error,
      if (hasFocus) WidgetState.focused,
    });

    statesController.addListener(handleStatesControllerChange);
  }

  @override
  void dispose() {
    statesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inputTheme = InputDecorationTheme.of(context);
    final defaultColor = inputTheme.fillColor ?? context.colors.secondaryContainer.lighten(50);
    final resolvedBorder = WidgetStateProperty.resolveAs<InputBorder?>(inputTheme.border, statesController.value);
    final effectiveBorderRadius =
        widget.borderRadius ?? (resolvedBorder is OutlineInputBorder ? resolvedBorder.borderRadius : BorderRadius.zero);

    Widget content = widget.child;

    if (widget.leading != null || widget.trailing != null) {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        // spacing: widget.spacing,
        children: <Widget>[
          ?widget.leading,
          Expanded(child: content),
          ?widget.trailing,
        ],
      );
    }

    // ~ inner container
    content = Container(
      decoration: BoxDecoration(
        color: WidgetStateProperty.resolveAs<Color?>(defaultColor, statesController.value),
        border: resolvedBorder != null ? Border.fromBorderSide(resolvedBorder.borderSide) : null,
        borderRadius: effectiveBorderRadius,
      ),
      padding: widget.padding,
      constraints: BoxConstraints(minWidth: double.infinity, minHeight: widget.minHeight ?? iFormFieldMinimumHeight),
      child: content,
    );

    if (widget.onTap != null) {
      content = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.enabled
            ? () {
                widget.onTap?.call();
                widget.focusNode?.requestFocus();
              }
            : null,
        child: content,
      );
    }

    if (hasError) {
      content = Shake(child: content);
    }

    if (_focusNode != null) {
      content = TextFieldTapRegion(
        onTapOutside: hasFocus ? (event) => _onTapOutside(context, event) : null,
        child: Focus(focusNode: _focusNode, onFocusChange: handleFocusUpdate, child: content),
      );
    }

    if (widget.suggestion != null) {
      final suggestion = DefaultTextStyle(
        style: context.textTheme.bodySmall!.copyWith(color: context.colors.onSecondaryContainer),
        child: widget.suggestion!,
      );

      // ~ outer container
      content = Container(
        decoration: BoxDecoration(borderRadius: effectiveBorderRadius, color: context.colors.secondaryContainer),
        clipBehavior: Clip.hardEdge,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            content,
            Container(
              foregroundDecoration: BoxDecoration(
                border: Border.all(color: context.colors.secondaryContainer),
                borderRadius: effectiveBorderRadius.copyWith(topLeft: Radius.zero, topRight: Radius.zero),
              ),
              child: Padding(
                padding: widget.suggestionPadding ?? widget.padding.copyWith(top: 8.0, bottom: 8.0),
                child: suggestion,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      // spacing: 4.0,
      children: <Widget>[
        content,

        if (hasError)
          Padding(
            padding: widget.padding.copyWith(top: 4.0, bottom: 0.0),
            child: FadeIn(
              from: Offset(0.0, -0.25),
              child: DefaultTextStyle(
                style: context.textTheme.bodySmall!
                    .copyWith(color: context.colors.error)
                    .merge(context.theme.inputDecorationTheme.errorStyle),
                child:
                    widget.errorBuilder?.call(context, widget.errorText!) ??
                    Text(widget.errorText!, overflow: TextOverflow.ellipsis, maxLines: 1),
              ),
            ),
          ),
      ],
    );
  }

  void _onTapOutside(BuildContext context, PointerDownEvent event) {
    if (!mounted) return;
    FocusScope.of(context).unfocus();
  }
}

enum _AmountPickerField { rate, quantity, totalAmount }

class _AmountPickerWidget extends StatefulWidget {
  const _AmountPickerWidget({super.key});

  @override
  State<_AmountPickerWidget> createState() => _AmountPickerWidgetState();
}

class _AmountPickerWidgetState extends State<_AmountPickerWidget> {
  late final FocusNode _rateFocusNode;
  late final FocusNode _quantityFocusNode;
  late final FocusNode _totalAmountFocusNode;
  late final ValueNotifier<bool> _showCalculator = ValueNotifier(false);
  late final ValueNotifier<String?> _calculatorExpression;
  _AmountPickerField? _focusedField;

  @override
  void initState() {
    super.initState();
    _rateFocusNode = FocusNode()..addListener(_updateCalculatorVisibility);
    _quantityFocusNode = FocusNode()..addListener(_updateCalculatorVisibility);
    _totalAmountFocusNode = FocusNode()..addListener(_updateCalculatorVisibility);
    _calculatorExpression = ValueNotifier(null);
  }

  @override
  void dispose() {
    _rateFocusNode.dispose();
    _quantityFocusNode.dispose();
    _totalAmountFocusNode.dispose();
    _calculatorExpression.dispose();
    super.dispose();
  }

  void _updateCalculatorVisibility() {
    if (!mounted) return;

    _focusedField = _rateFocusNode.hasFocus
        ? _AmountPickerField.rate
        : _quantityFocusNode.hasFocus
        ? _AmountPickerField.quantity
        : _totalAmountFocusNode.hasFocus
        ? _AmountPickerField.totalAmount
        : null;
    _showCalculator.value = _focusedField != null;
  }

  void _handleCalculatorExpression(CalculatorExpression? expression, num? result) {
    _calculatorExpression.value = expression?.toString();
    if (_focusedField == null || result == null) return;

    final cubit = context.read<EditTransactionCubit>();
    switch (_focusedField!) {
      case _AmountPickerField.rate:
        cubit.updateRate(result.toDouble());
        break;
      case _AmountPickerField.quantity:
        cubit.updateQuantity(result.toDouble());
        break;
      case _AmountPickerField.totalAmount:
        if (cubit.state.canEditAmount) {
          cubit.updateAmount(result.toDouble());
        }
        break;
    }
  }

  void _handleCalculatorConfirm(num? value) {
    if (_focusedField == null || value == null) return;

    final cubit = context.read<EditTransactionCubit>();
    switch (_focusedField!) {
      case _AmountPickerField.rate:
        cubit.updateRate(value.toDouble());
        break;
      case _AmountPickerField.quantity:
        cubit.updateQuantity(value.toDouble());
        break;
      case _AmountPickerField.totalAmount:
        if (cubit.state.canEditAmount) {
          cubit.updateAmount(value.toDouble());
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<EditTransactionCubit>();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        spacing: iFormFieldsInterSpacing,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // ~ Unit price & No. of units
          BlocSelector<EditTransactionCubit, EditTransactionState, bool>(
            selector: (state) => state.canEditRateAndQnty,
            builder: (context, isVisible) {
              if (!isVisible) {
                return SizedBox(width: double.infinity);
              }

              return Row(
                spacing: iFormFieldsInterSpacing,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // ~ Rate (Unit price)
                  Expanded(
                    child: Column(
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
                              child: Text(label, overflow: TextOverflow.ellipsis),
                            );
                          },
                        ),

                        const Gap(iFormFieldLabelSpacing),

                        // ~ Rate field
                        BlocBuilder<EditTransactionCubit, EditTransactionState>(
                          buildWhen: (prev, curr) {
                            return prev.rate != curr.rate ||
                                prev.rateError != curr.rateError ||
                                (prev.status != curr.status && curr.isError && curr.rateError != null);
                          },
                          builder: (context, state) {
                            $logger.i('Rate is Rebuilding');
                            return _TappableFocusableField(
                              focusNode: _rateFocusNode,
                              errorText: state.rateError,
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

                        // ~ Calculator expression preview
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: ValueListenableBuilder(
                              valueListenable: _calculatorExpression,
                              builder: (context, expression, _) {
                                if (expression == null) return const SizedBox.shrink();
                                return Text(expression, style: TextStyle(fontSize: 13.0), textAlign: TextAlign.right);
                              },
                            ),
                          ),
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

                              child: Text(label, overflow: TextOverflow.ellipsis),
                            );
                          },
                        ),
                        // ~ Quantity field
                        BlocBuilder<EditTransactionCubit, EditTransactionState>(
                          buildWhen: (prev, curr) {
                            return prev.qnty != curr.qnty ||
                                prev.qntyError != curr.qntyError ||
                                (prev.status != curr.status && curr.isError && curr.qntyError != null);
                          },
                          builder: (context, state) {
                            $logger.i('Quantity is Rebuilding');
                            return _TappableFocusableField(
                              focusNode: _quantityFocusNode,
                              errorText: state.qntyError,
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
              );
            },
          ),

          // ~ Total amount title
          Column(
            spacing: iFormFieldLabelSpacing,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Expanded(child: Text('Total amount', overflow: TextOverflow.ellipsis)),

                    // ~ Auto calculate
                    BlocSelector<EditTransactionCubit, EditTransactionState, bool>(
                      selector: (state) => [AmcGenre.insurance, AmcGenre.misc].contains(state.amc?.genre),
                      builder: (context, disabled) {
                        if (disabled) {
                          return SizedBox.shrink();
                        }

                        return BlocSelector<EditTransactionCubit, EditTransactionState, bool>(
                          selector: (state) => state.autoAmount,
                          builder: (context, autoAmount) {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text('Auto calculate', style: context.textTheme.labelSmall),
                                SizedBox(
                                  height: 20.0,
                                  child: FittedBox(
                                    fit: BoxFit.fill,
                                    child: Switch(
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      value: autoAmount,
                                      onChanged: disabled ? null : (value) => cubit.updateAutoAmountMode(value),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
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
              return _TappableFocusableField(
                enabled: state.canEditAmount,
                focusNode: _totalAmountFocusNode,
                errorText: state.totalAmountError,
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

          // ~ Calculator expression preview
          ValueListenableBuilder(
            valueListenable: _calculatorExpression,
            builder: (context, expression, _) {
              if (expression == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(expression, style: context.theme.inputDecorationTheme.helperStyle),
              );
            },
          ),

          // ~ Calculator
          AnimatedSize(
            duration: 500.ms,
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: ValueListenableBuilder(
              valueListenable: _showCalculator,
              builder: (context, showCalculator, calculator) {
                if (showCalculator) {
                  return calculator!;
                }
                return SizedBox(width: double.infinity);
              },
              child: InveslyCalculatorWidget(
                onPressed: _handleCalculatorExpression,
                onConfirm: _handleCalculatorConfirm,
              ),
            ),
          ),

          // ~ Confirm Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(onPressed: () {}, child: Text('Confirm')),
          ),
        ],
      ),
    );
  }
}
