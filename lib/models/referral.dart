import 'package:phsyio_up/models/treatment_plan.dart';

class Referral {
  int? id;
  String? name;
  double? cashbackPercentage;
  List<TreatmentPlan>? treatmentPlans;
  Referral({
    required this.id,
    required this.name,
    required this.cashbackPercentage,
    required this.treatmentPlans,
  });

  factory Referral.fromJson(Map<String, dynamic> json) {
    return Referral(
      id: json['ID'] ?? 0,
      name: json['name'] ?? '',
      treatmentPlans: (json['treatment_plans'] as List<dynamic>?)?.map((e) => TreatmentPlan.fromJson(e)).toList() ?? [],
      cashbackPercentage: double.parse(json['cashback_percentage'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'cashback_percentage': cashbackPercentage,
      'treatment_plans': treatmentPlans,
    };
  }
}