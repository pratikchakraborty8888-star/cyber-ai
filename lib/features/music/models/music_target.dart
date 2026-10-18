class MusicTarget {
  final String id;
  final String displayName;
  final String packageName;
  final bool isInstalled;
  final bool isDefaultSupported;

  const MusicTarget({
    required this.id,
    required this.displayName,
    required this.packageName,
    this.isInstalled = false,
    this.isDefaultSupported = true,
  });

  MusicTarget copyWith({
    String? id,
    String? displayName,
    String? packageName,
    bool? isInstalled,
    bool? isDefaultSupported,
  }) {
    return MusicTarget(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      packageName: packageName ?? this.packageName,
      isInstalled: isInstalled ?? this.isInstalled,
      isDefaultSupported: isDefaultSupported ?? this.isDefaultSupported,
    );
  }
}
