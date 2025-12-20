import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:invesly/accounts/cubit/accounts_cubit.dart';
import 'package:invesly/accounts/edit_account/view/edit_account_screen.dart';
import 'package:invesly/common/extensions/buildcontext_extension.dart';
import 'package:invesly/common/presentations/animations/scroll_to_hide.dart';
import 'package:invesly/common/presentations/widgets/popups.dart';
import 'package:invesly/transactions/edit_transaction/edit_transaction_screen.dart';

class AddTransactionButton extends StatelessWidget {
  const AddTransactionButton({this.scrollController, super.key});

  final ScrollController? scrollController;

  void _handleNewTransactionPressed(BuildContext context) async {
    final accountsState = context.read<AccountsCubit>().state;

    // Load accounts if not loaded
    if (accountsState is AccountsInitialState) {
      await context.read<AccountsCubit>().fetchAccounts();
    }
    if (!context.mounted) return;
    if (accountsState is AccountsErrorState) {
      // showErrorDialog(context);
      return;
    }
    if (accountsState is AccountsLoadedState) {
      if (accountsState.accounts.isEmpty) {
        final confirmed = await showConfirmDialog(
          context,
          title: 'Oops!',
          icon: const Icon(Icons.warning_amber_rounded),
          content: const Text(
            'You must have at least one no-archived account before you can start creating transactions',
          ),
          confirmText: 'Continue',
        );

        if (!context.mounted) return;
        if (confirmed ?? false) {
          context.push(const EditAccountScreen());
        }
        return;
      }

      context.push(const EditTransactionScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget child = const Padding(padding: EdgeInsets.only(left: 8.0), child: Text('New transaction'));

    if (scrollController != null) {
      child = ScrollToHide(scrollController: scrollController!, hideAxis: Axis.horizontal, child: child);
    }

    return FloatingActionButton.extended(
      heroTag: null,
      onPressed: () => _handleNewTransactionPressed(context),
      icon: const Icon(Icons.add_rounded),
      extendedPadding: const EdgeInsetsDirectional.only(start: 16.0, end: 16.0),
      extendedIconLabelSpacing: 0.0,
      label: child,
    );
  }
}
