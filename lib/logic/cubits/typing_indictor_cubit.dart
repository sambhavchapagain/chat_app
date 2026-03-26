import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'typing_indictor_state.dart';

class TypingIndictorCubit extends Cubit<TypingIndictorState> {
  TypingIndictorCubit() : super(TypingIndictorInitial());
}
