import 'package:invesly/accounts/model/account_model.dart';
import 'package:invesly/amcs/model/amc_model.dart';
import 'package:invesly/transactions/model/transaction_model.dart';
import 'package:invesly/transactions/model/transaction_repository.dart';
import 'package:invesly/common_libs.dart';

part 'edit_transaction_state.dart';

class EditTransactionCubit extends Cubit<EditTransactionState> {
  EditTransactionCubit({required TransactionRepository repository, InveslyTransaction? initialInvestment})
    : _repository = repository,
      super(
        EditTransactionState(
          id: initialInvestment?.id,
          account: initialInvestment?.account,
          quantity: initialInvestment?.quantity,
          amount: initialInvestment?.totalAmount,
          type: (initialInvestment?.totalAmount.isNegative ?? false)
              ? TransactionType.redeemed
              : TransactionType.invested,
          amc: initialInvestment?.amc,
          notes: initialInvestment?.note,
        ),
      );

  final TransactionRepository _repository;

  void updateAccount(InveslyAccount account) {
    emit(state.copyWith(account: account));
  }

  void updateQuantity(double result) {
    emit(state.copyWith(quantity: result));
  }

  void updateAmount(double result) {
    emit(state.copyWith(amount: result));
  }

  void updateTransactionType(TransactionType type) {
    emit(state.copyWith(type: type));
  }

  void updateAmc(InveslyAmc amc) {
    emit(state.copyWith(amc: amc));
  }

  void updateDate(DateTime date) {
    emit(state.copyWith(date: date));
  }

  void updateNotes(String notes) {
    emit(state.copyWith(notes: notes));
  }

  Future<void> save() async {
    if (!state.canSave) {
      emit(state.copyWith(status: EditTransactionStatus.failure));
      return;
    }

    final inv = InveslyTransaction(
      id: state.id ?? $uuid.v1(),
      account: state.account!,
      amc: state.amc,
      quantity: state.quantity ?? 0.0,
      totalAmount: state.amount!,
      investedOn: state.date ?? DateTime.now(),
      note: state.notes,
    );
    $logger.i(inv);

    emit(state.copyWith(status: EditTransactionStatus.loading));
    try {
      await _repository.saveTransaction(inv);
      emit(state.copyWith(status: EditTransactionStatus.success));
    } on Exception catch (e) {
      $logger.e(e);
      emit(state.copyWith(status: EditTransactionStatus.failure));
    }
  }
}
