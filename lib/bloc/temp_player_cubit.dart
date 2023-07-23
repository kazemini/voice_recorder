import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'temp_player_state.dart';

class TempPlayerCubit extends Cubit<TempPlayerState> {
  TempPlayerCubit() : super(TempPlayerInitial());
}
