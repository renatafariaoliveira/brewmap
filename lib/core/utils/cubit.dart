import 'package:flutter_bloc/flutter_bloc.dart';

extension SafeEmit<T> on BlocBase<T> {
  void safeEmit(T state) {
    if (!isClosed) {
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      emit(state);
    }
  }
}
