import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phsyio_up/models/treatment_plan.dart';
import 'package:phsyio_up/dio_helper.dart';
import 'package:phsyio_up/main.dart';
part 'treatment_packages_state.dart';

class TreatmentPackagesCubit extends Cubit<TreatmentPackagesState> {
  TreatmentPackagesCubit() : super(TreatmentPackagesInitial());
  static TreatmentPackagesCubit get(context) => BlocProvider.of(context);

  final createFormKey = GlobalKey<FormState>();

  late TextEditingController createDescriptionController;
  late TextEditingController createSessionsCountController;
  late TextEditingController createPriceController;


  void initCreate() {
    createDescriptionController = TextEditingController();
    createSessionsCountController = TextEditingController();
    createPriceController = TextEditingController();
  }

  Future<void> addTreatment(BuildContext context) async {
    if (createFormKey.currentState!.validate()) {
      // Create new patient object
      final newTreatmentPackage = SuperTreatmentPlan(
        description: createDescriptionController.text,
        sessionsCount: int.parse(createSessionsCountController.text),
        price: double.parse(createPriceController.text),
      );

      // Call the API to create the new patient
      try {
         await postData(
          "$ServerIP/api/protected/AddSuperTreatment", // Replace with your API endpoint
          newTreatmentPackage.toJson(), // Convert patient object to JSON
        );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Treatment Package Added Successfully')),
          );
          Navigator.push(context, MaterialPageRoute(builder: (_) => MainWidget()));
       
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding treatment package: $e')),
        );
      }
    }
  }
}
