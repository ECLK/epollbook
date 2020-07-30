import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:mobile/models/elector.dart';
import 'package:mobile/models/info.dart';
import 'package:mobile/repository/dto/instance_data.dart';
import 'package:mobile/repository/repository.dart';
import 'package:logger/logger.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc() : super(AppInitial());

  Repository _repository = Repository();

  List<Elector> _electors;
  List<String> _inQueueIDs;
  List<Elector> _inQueue;

  @override
  Stream<AppState> mapEventToState(
    AppEvent event,
  ) async* {
    if (event is FetchMeta) {
      yield AppLoading();

      bool hasInstanceData = await _repository.checkInstanceData();

      if (hasInstanceData) {
        yield AppMethodSelect();
      } else {
        final List<Info> _meta = await _repository.fetchMeta(event.election);

        if (_meta != null &&
            _meta.first != null &&
            _meta.first.stationId != "-1")
          yield AppMetaLoaded(meta: _meta);
        else
          yield AppError("Meta loading failed");
      }
    } else if (event is SaveMeta) {
      yield AppLoading();

      await _repository.saveInstanceData(
          event.election, event.district, event.division, event.station);

      yield AppMethodSelect();
    } else if (event is FetchElectors) {
      yield AppLoading();

      InstanceData instanceData = await _repository.loadInstanceData();

      _electors = await _repository.fetchElectors(instanceData.election,
          instanceData.district, instanceData.division, instanceData.station);

      _inQueueIDs = await _repository.fetchInQueue(instanceData.election,
          instanceData.district, instanceData.division, instanceData.station);

      _inQueue = _electors
          .where((elector) => _inQueueIDs.contains(elector.id))
          .toList();

      if (_electors != null &&
          _electors.first != null &&
          _electors.first.id != "-1") {
        if (event.option == 0)
          yield AppElectorsLoaded(electors: _electors);
        else
          yield AppElectorsLoaded(electors: _inQueue);
      } else {
        yield AppError("Electors loading failed");
      }
    } else if (event is ChangeMeta) {
      yield AppLoading();

      final List<Info> _meta = await _repository.fetchMeta(event.election);

      if (_meta != null && _meta.first != null && _meta.first.stationId != "-1")
        yield AppMetaLoaded(meta: _meta);
      else
        yield AppError("Meta loading failed");
    } else if (event is ChangeMethod) {
      yield AppMethodSelect();
    }
  }
}
