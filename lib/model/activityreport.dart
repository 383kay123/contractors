class ActivityReport {
  final String completionDate;
  final String reportingDate;
  final String farmReference;
  final String activityDone;
  final String subActivityDone;
  final String farmerName;
  final String farmSize;
  final String farmLocation;

  ActivityReport({
    required this.completionDate,
    required this.reportingDate,
    required this.farmReference,
    required this.activityDone,
    required this.subActivityDone,
    required this.farmerName,
    required this.farmSize,
    required this.farmLocation,
  });

  Map<String, dynamic> toMap() {
    return {
      'completion_date': completionDate,
      'reporting_date': reportingDate,
      'farm_reference': farmReference,
      'activity_done': activityDone,
      'sub_activity_done': subActivityDone,
      'farmer_name': farmerName,
      'farm_size': farmSize,
      'farm_location': farmLocation,
    };
  }

  static ActivityReport fromMap(Map<String, dynamic> map) {
    return ActivityReport(
      completionDate: map['completion_date'],
      reportingDate: map['reporting_date'],
      farmReference: map['farm_reference'],
      activityDone: map['activity_done'],
      subActivityDone: map['sub_activity_done'],
      farmerName: map['farmer_name'],
      farmSize: map['farm_size'],
      farmLocation: map['farm_location'],
    );
  }
}
