enum ActionType {
  answerQuestion,
  openApp,
  searchMusic,
  openMusicApp,
  createWebsite,
  openSettings,
  stopSpeaking,
  unsupportedAction,
}

class ActionIntent {
  final ActionType type;
  final String rawQuery;
  final Map<String, dynamic> parameters;
  final String? directResponse;

  const ActionIntent({
    required this.type,
    required this.rawQuery,
    this.parameters = const {},
    this.directResponse,
  });

  @override
  String toString() {
    return 'ActionIntent(type: $type, rawQuery: "$rawQuery", parameters: $parameters)';
  }
}
