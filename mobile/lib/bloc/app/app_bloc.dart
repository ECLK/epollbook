import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:mobile/models/elector.dart';
import 'package:mobile/models/info.dart';
import 'package:mobile/repository/repository.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc() : super(AppInitial());

  Repository _repository = Repository();

  @override
  Stream<AppState> mapEventToState(
    AppEvent event,
  ) async* {
    if (event is FetchMeta) {
      yield AppLoading();

      final List<Info> _meta = await _repository.fetchMeta(event.election);

      if (_meta != null && _meta.first != null && _meta.first.stationId != "-1")
        yield AppMetaLoaded(meta: _meta);
      else
        yield AppError("Meta loading failed");
    } else if (event is FetchElectors) {
      yield AppLoading();

      final List<Elector> _electors = await _repository.fetchElectors(
          event.election, event.district, event.division, event.station);

      if (_electors != null &&
          _electors.first != null &&
          _electors.first.id != "-1")
        yield AppElectorsLoaded(all: _electors);
      else
        yield AppError("Meta loading failed");
    }
  }
}
