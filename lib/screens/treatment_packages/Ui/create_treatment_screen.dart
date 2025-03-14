import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phsyio_up/components/app_bar.dart';
import 'package:phsyio_up/screens/treatment_packages/cubit/treatment_packages_cubit.dart';

class CreateTreatmentScreen extends StatefulWidget {
  const CreateTreatmentScreen({super.key});

  @override
  _CreateTreatmentScreenState createState() => _CreateTreatmentScreenState();
}

class _CreateTreatmentScreenState extends State<CreateTreatmentScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TreatmentPackagesCubit(),
      child: BlocBuilder<TreatmentPackagesCubit, TreatmentPackagesState>(
        builder: (context, state) {
          TreatmentPackagesCubit cubit = TreatmentPackagesCubit.get(context);
          return Scaffold(
            appBar: CustomAppBar(title: "Add Package", actions: []),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: cubit.createFormKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: cubit.createDescriptionController,
                      decoration: InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder()),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: cubit.createSessionsCountController,
                      decoration: const InputDecoration(
                        labelText: 'Sessions Count',
                        prefixIcon: Icon(Icons.numbers),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final count = double.tryParse(value);
                          if (count == null || count < 1 || count > 100) {
                            return "Enter a valid count (1-100)";
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: cubit.createPriceController,
                      decoration: const InputDecoration(
                        labelText: 'Price',
                        prefixIcon: Icon(Icons.money),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Enter A Correct Price";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      onPressed: (){
                        cubit.addTreatment(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 10.0),
                        child: Text('Add Package'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
