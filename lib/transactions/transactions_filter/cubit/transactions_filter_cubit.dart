import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'transactions_filter_state.dart';

class TransactionsFilterCubit extends Cubit<TransactionsFilterState> {
  TransactionsFilterCubit() : super(TransactionsFilterInitial());
}
