import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:phsyio_up/components/dio_helper.dart';
import 'package:phsyio_up/main.dart';
import 'package:phsyio_up/models/therapist.dart';

part 'clinic_state.dart';

class ClinicCubit extends Cubit<ClinicState> {
  ClinicCubit() : super(ClinicInitial());
  static ClinicCubit get(context) => BlocProvider.of(context);

  late Future<List<Therapist>> therapistsFuture;
  bool isRefreshing = false;

  void initList() {
    therapistsFuture = fetchData();
  }

  Future<void> refreshTherapists() async {
    
      isRefreshing = true;
    emit(RefreshTherapistsLoading());
    
    therapistsFuture = fetchData();
    
    
      isRefreshing = false;
    emit(RefreshTherapistsSuccess( await therapistsFuture));
  }

  Future<List<Therapist>> fetchData() async {
    List<Therapist> therapists = [];
    try {
      dynamic response = await getData("$ServerIP/api/protected/GetTherapists");
      therapists = parseTherapists(response);
    } catch (e) {
      print("Error fetching data: $e");
      // We'll handle this in the UI
    }
    return therapists;
  }
}
