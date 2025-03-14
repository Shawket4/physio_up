import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phsyio_up/components/app_bar.dart';
import 'package:phsyio_up/models/referral.dart';
import 'package:phsyio_up/screens/referral/cubit/referral_cubit.dart';

class EditReferralScreen extends StatefulWidget {
  final Referral referral;
  const EditReferralScreen({super.key, required this.referral});

  @override
  _EditReferralScreenState createState() => _EditReferralScreenState();
}

class _EditReferralScreenState extends State<EditReferralScreen> {
  // Dropdown value for gender

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReferralCubit()..initEdit(widget.referral),
      child: BlocBuilder<ReferralCubit, ReferralState>(
        builder: (context, state) {
          ReferralCubit cubit = ReferralCubit.get(context);
          return Scaffold(
            appBar: CustomAppBar(title: "Edit Referral", actions: []),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: cubit.editFormKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: cubit.editNameController,
                      decoration: InputDecoration(
                          labelText: 'Name',
                          prefixIcon: Icon(Icons.person),
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
                      controller: cubit.editCashbackPercentage,
                      decoration: const InputDecoration(
                        labelText: 'Cashback Percentage',
                        prefixIcon: Icon(Icons.percent),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final discount = double.tryParse(value);
                          if (discount == null ||
                              discount < 1 ||
                              discount > 100) {
                            return "Enter a valid percentage (1-100)";
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      onPressed:(){
                        cubit.editReferral(widget.referral, context);
                      } ,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 10.0),
                        child: Text('Edit Referral'),
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
