import 'package:invesly/accounts/model/account_model.dart';
import 'package:invesly/amcs/model/amc_model.dart';
import 'package:invesly/transactions/model/transaction_model.dart';
import 'package:invesly/transactions/model/transaction_repository.dart';
import 'package:invesly/common_libs.dart';

part 'edit_transaction_state.dart';

class EditTransactionCubit extends Cubit<EditTransactionState> {
  EditTransactionCubit({required TransactionRepository repository, InveslyTransaction? initial})
    : _repository = repository,
      super(
        EditTransactionState(
          id: initial?.id,
          account: initial?.account,
          quantity: initial?.quantity,
          amount: initial?.totalAmount,
          type: (initial?.totalAmount.isNegative ?? false) ? TransactionType.redeemed : TransactionType.invested,
          genre: initial?.amc?.genre ?? AmcGenre.misc,
          amc: initial?.amc,
          notes: initial?.note,
        ),
      );

  final TransactionRepository _repository;

  void updateAccount(InveslyAccount account) {
    emit(state.copyWith(account: account));
  }

  void updateQuantity(double value) {
    emit(state.copyWith(quantity: value));
  }

  void updateRate(double value) {
    emit(state.copyWith(rate: value));
  }

  void updateAmount(double value) {
    emit(state.copyWith(amount: value));
  }

  void updateTransactionType(TransactionType type) {
    emit(state.copyWith(type: type));
  }

  void updateGenre(AmcGenre genre) {
    emit(state.copyWith(genre: genre));
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
      totalAmount: state.genre == TransactionType.invested ? state.amount!.abs() : -state.amount!.abs(),
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
