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
          genre: initial?.amc?.genre ?? AmcGenre.mf,
          autoAmount: [AmcGenre.mf, AmcGenre.stock].contains(initial?.amc?.genre ?? AmcGenre.mf),
          amc: initial?.amc,
          notes: initial?.note,
        ),
      );

  final TransactionRepository _repository;

  void updateAccount(InveslyAccount account) {
    emit(state.copyWith(account: account));
  }

  void updateQuantity(double quantity) {
    emit(
      state.copyWith(
        status: EditTransactionStatus.edited,
        quantity: quantity,
        amount: state.canEditAmount ? null : quantity * (state.rate ?? 0.0),
      ),
    );
  }

  void updateRate(double rate) {
    emit(
      state.copyWith(
        status: EditTransactionStatus.edited,
        rate: rate,
        amount: state.canEditAmount ? null : rate * (state.quantity ?? 0.0),
      ),
    );
  }

  void updateAmount(double value) {
    emit(state.copyWith(status: EditTransactionStatus.edited, amount: value));
  }

  void updateAutoAmount(bool value) {
    emit(state.copyWith(autoAmount: value, amount: value ? (state.rate ?? 0.0) * (state.quantity ?? 0.0) : null));
  }

  void updateTransactionType(TransactionType type) {
    emit(state.copyWith(type: type));
  }

  void updateGenre(AmcGenre genre) {
    emit(state.copyWith(genre: genre));
  }

  void updateAmc(InveslyAmc amc) {
    emit(state.copyWith(status: EditTransactionStatus.edited, amc: amc));
  }

  void updateDate(DateTime date) {
    emit(state.copyWith(status: EditTransactionStatus.edited, date: date));
  }

  void updateNotes(String notes) {
    emit(state.copyWith(status: EditTransactionStatus.edited, notes: notes));
  }

  void requestPop(bool value) {
    emit(state.copyWith(isPopping: value));
  }

  Future<void> save() async {
    if (!state.canSave) {
      emit(state.copyWith(status: EditTransactionStatus.failed));
      return;
    }

    final inv = InveslyTransaction(
      id: state.id ?? $uuid.v1(),
      account: state.account!,
      amc: state.amc,
      quantity: state.canEditRateAndQnty ? state.quantity ?? 0.0 : 0.0,
      rate: state.canEditRateAndQnty ? state.rate ?? 0.0 : 0.0,
      totalAmount: state.type == TransactionType.invested ? state.amount!.abs() : -state.amount!.abs(),
      investedOn: state.date ?? DateTime.now(),
      note: state.notes,
    );
    $logger.i(inv);

    emit(state.copyWith(status: EditTransactionStatus.saving));
    try {
      await _repository.saveTransaction(inv);
      emit(state.copyWith(status: EditTransactionStatus.saved));
    } on Exception catch (e) {
      $logger.e(e);
      emit(state.copyWith(status: EditTransactionStatus.failed));
    }
  }
}
