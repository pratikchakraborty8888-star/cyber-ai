class AppInfo {
  final String name;
  final String packageName;

  const AppInfo({required this.name, required this.packageName});

  Map<String, dynamic> toJson() {
    return {'name': name, 'packageName': packageName};
  }

  factory AppInfo.fromJson(Map<String, dynamic> json) {
    return AppInfo(
      name: json['name'] as String? ?? 'App',
      packageName: json['packageName'] as String? ?? '',
    );
  }
}
