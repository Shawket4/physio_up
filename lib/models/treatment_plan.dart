class TreatmentPlan {
  int? id;
  int? superTreatmentPlanId;
  int? remaining;
  double? discount;
  int? referralID;
  int? patientId;
  SuperTreatmentPlan? superTreatmentPlan;
  String? date;
  double? totalPrice;
  bool? isPaid;
  
  TreatmentPlan({
    this.id,
    this.superTreatmentPlanId,
    this.remaining,
    this.discount,
    this.referralID,
    this.patientId,
    this.superTreatmentPlan,
    this.date,
    this.totalPrice,
    this.isPaid,
  });

  factory TreatmentPlan.fromJson(Map<String, dynamic> json) {
    return TreatmentPlan(
      id: json['ID'],
      superTreatmentPlanId: json['super_treatment_plan_id'],
      remaining: json['remaining'],
      discount: double.parse(json['discount'].toString()),
      referralID: json['referral_id'] ?? 0,
      patientId: json['patient_id'],
      superTreatmentPlan: SuperTreatmentPlan.fromJson(json["super_treatment_plan"]),
      date: json['date'],
      totalPrice: double.parse(json['total_price'].toString()),
      isPaid: json['is_paid'],
    );
  }
}

class SuperTreatmentPlan {
  int? id;
  String? description;
  double? price;
  int? sessionsCount;
  SuperTreatmentPlan({
    this.id,
    this.description,
    this.price,
    this.sessionsCount,
  });

  factory SuperTreatmentPlan.fromJson(Map<String, dynamic> json) {
    return SuperTreatmentPlan(
      id: json['ID'],
      description: json['description'],
      price: double.parse(json["price"].toString()),
      sessionsCount: json['sessions_count'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'price': price,
      'sessions_count': sessionsCount,
    };
  }
  Map<String, dynamic> toJsonWithID() {
    return {
      'id': id,
      'description': description,
      'price': price,
      'sessions_count': sessionsCount,
    };
  }
}