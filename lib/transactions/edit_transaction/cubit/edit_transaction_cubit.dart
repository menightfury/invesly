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
          qnty: initial?.quantity,
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
          amc: initial?.amc,
          notes: initial?.note,
        ),
      );

  final TransactionRepository _repository;

  void updateAccount(int accountId) {
    if (accountId.isNegative || accountId.isInfinite || accountId.isNaN) {
      emit(state.copyWith(accountError: () => 'Invalid account'));
      return;
    }

    emit(state.copyWith(status: EditTransactionStatus.edited, accountId: accountId, accountError: () => null));
  }

  void updateAmc(InveslyAmc amc) {
    emit(state.copyWith(status: EditTransactionStatus.edited, amc: amc, amcError: () => null));
  }

  void updateTransactionType(TransactionType type) {
    emit(state.copyWith(type: type));
  }

  // void updateGenre(AmcGenre genre) {
  //   emit(state.copyWith(genre: genre));
  // }

  void updateDate(DateTime date) {
    emit(state.copyWith(status: EditTransactionStatus.edited, date: date));
  }

  void updateRate(double rate) {
    if (rate.isNegative || rate.isInfinite || rate.isNaN) {
      emit(state.copyWith(rateError: () => 'Invalid rate', totalAmountError: () => 'Invalid amount'));
      return;
    }

    emit(
      state.copyWith(
        status: EditTransactionStatus.edited,
        rate: rate,
        totalAmount: state.canEditAmount ? null : rate * (state.qnty ?? 0.0),
        rateError: () => null,
        totalAmountError: () => null,
      ),
    );
  }

  void updateQuantity(double qnty) {
    if (qnty.isNegative || qnty.isInfinite || qnty.isNaN) {
      emit(state.copyWith(qntyError: () => 'Invalid quantity', totalAmountError: () => 'Invalid amount'));
      return;
    }

    emit(
      state.copyWith(
        status: EditTransactionStatus.edited,
        qnty: qnty,
        totalAmount: state.canEditAmount ? null : qnty * (state.rate ?? 0.0),
        qntyError: () => null,
        totalAmountError: () => null,
      ),
    );
  }

  void updateAmount(double amount) {
    if (amount.isNegative || amount.isInfinite || amount.isNaN) {
      emit(state.copyWith(totalAmountError: () => 'Invalid amount'));
      return;
    }

    if (amount.isZero) {
      emit(state.copyWith(totalAmountError: () => 'Amount can\'t be zero'));
      return;
    }

    emit(state.copyWith(status: EditTransactionStatus.edited, totalAmount: amount, totalAmountError: () => null));
  }

  void updateAutoAmountMode(bool value) {
    emit(state.copyWith(autoAmount: value, totalAmount: value ? (state.rate ?? 0.0) * (state.qnty ?? 0.0) : null));
  }

  void updateNotes(String notes) {
    emit(state.copyWith(status: EditTransactionStatus.edited, notes: notes));
  }

  Future<void> save() async {
    emit(state.copyWith(status: EditTransactionStatus.saving));

    final accountError = state.isAccountValid ? null : state.accountError ?? 'Valid account is required';
    final amcError = state.isAmcValid ? null : state.amcError ?? 'AMC is required';
    final rateError = state.isRateValid ? null : state.rateError ?? 'Rate is required';
    final qntyError = state.isQntyValid ? null : state.qntyError ?? 'Quantity is required';
    final totalAmountError = state.isTotalAmountValid ? null : state.totalAmountError ?? 'Amount is required';

    if (!state.isFormValid) {
      emit(
        state.copyWith(
          status: EditTransactionStatus.error,
          accountError: () => accountError,
          amcError: () => amcError,
          rateError: () => rateError,
          qntyError: () => qntyError,
          totalAmountError: () => totalAmountError,
        ),
      );
      return;
    }

    final inv = TransactionInDb(
      id: state.id ?? 0,
      accountId: state.accountId!,
      amcId: state.amc!.id,
      quantity: state.canEditRateAndQnty ? state.qnty ?? 0.0 : 0.0,
      rate: state.canEditRateAndQnty ? state.rate ?? 0.0 : 0.0,
      totalAmount: state.type == TransactionType.invested ? state.totalAmount!.abs() : -state.totalAmount!.abs(),
      date: (state.date ?? DateTime.now().startOfDay).millisecondsSinceEpoch,
      note: state.notes,
    );
    $logger.i(inv);

    try {
      await _repository.saveTransaction(inv, state.isNewTransaction);
      emit(state.copyWith(status: EditTransactionStatus.saved));
    } on Exception catch (e) {
      $logger.e(e);
      emit(state.copyWith(status: EditTransactionStatus.failed));
    }
  }
}
