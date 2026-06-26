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
          accountId: initial?.accountId,
          quantity: initial?.quantity,
          rate: initial?.rate,
          totalAmount: initial?.totalAmount,
          autoAmount: [AmcGenre.mf, AmcGenre.stock].contains(initial?.amc.genre ?? AmcGenre.mf),
          type: (initial?.totalAmount.isNegative ?? false)
              ? (initial?.quantity?.isZero ?? true)
                    ? TransactionType.dividend
                    : TransactionType.redeemed
              : TransactionType.invested,
          genre: initial?.amc.genre ?? AmcGenre.mf,
          date: initial?.investedOn ?? DateTime.now().startOfDay,
          amcId: initial?.amcId,
          notes: initial?.note,
        ),
      );

  final TransactionRepository _repository;

  void updateAccount(int accountId) {
    emit(state.copyWith(accountId: accountId));
  }

  void updateQuantity(double quantity) {
    emit(
      state.copyWith(
        status: EditTransactionStatus.edited,
        quantity: quantity,
        totalAmount: state.canEditAmount ? null : quantity * (state.rate ?? 0.0),
      ),
    );
  }

  void updateRate(double rate) {
    emit(
      state.copyWith(
        status: EditTransactionStatus.edited,
        rate: rate,
        totalAmount: state.canEditAmount ? null : rate * (state.quantity ?? 0.0),
      ),
    );
  }

  void updateAmount(double value) {
    emit(state.copyWith(status: EditTransactionStatus.edited, totalAmount: value));
  }

  void updateAutoAmountMode(bool value) {
    emit(state.copyWith(autoAmount: value, totalAmount: value ? (state.rate ?? 0.0) * (state.quantity ?? 0.0) : null));
  }

  void updateTransactionType(TransactionType type) {
    emit(state.copyWith(type: type));
  }

  void updateGenre(AmcGenre genre) {
    emit(state.copyWith(genre: genre));
  }

  void updateAmc(String? amcId) {
    emit(state.copyWith(status: EditTransactionStatus.edited, amcId: () => amcId));
  }

  void updateDate(DateTime date) {
    emit(state.copyWith(status: EditTransactionStatus.edited, date: date));
  }

  void updateNotes(String notes) {
    emit(state.copyWith(status: EditTransactionStatus.edited, notes: notes));
  }

  Future<void> save() async {
    if (!state.canSave) {
      emit(state.copyWith(status: EditTransactionStatus.error));
      return;
    }

    final inv = TransactionInDb(
      id: state.id ?? 0,
      accountId: state.accountId!,
      amcId: state.amcId!,
      quantity: state.canEditRateAndQnty ? state.quantity ?? 0.0 : 0.0,
      rate: state.canEditRateAndQnty ? state.rate ?? 0.0 : 0.0,
      totalAmount: state.type == TransactionType.invested ? state.totalAmount!.abs() : -state.totalAmount!.abs(),
      date: (state.date ?? DateTime.now().startOfDay).millisecondsSinceEpoch,
      note: state.notes,
    );
    $logger.i(inv);

    emit(state.copyWith(status: EditTransactionStatus.saving));
    try {
      await _repository.saveTransaction(inv);
      emit(state.copyWith(status: EditTransactionStatus.saved));
    } on Exception catch (e) {
      $logger.e(e);
      emit(state.copyWith(status: EditTransactionStatus.error));
    }
  }
}
