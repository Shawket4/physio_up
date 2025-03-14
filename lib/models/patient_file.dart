class PatientFile {
  final String name;
  final double size; // Size in bytes

  PatientFile({required this.name, required this.size});

  factory PatientFile.fromJson(Map<String, dynamic> json) {
    print(json);
    return PatientFile(
      name: json['name'],
      size: double.parse(json['size'].toString()),
    );
  }

  // Convert size to megabytes (MB)
  String get sizeInMB {
    return '${(size / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}