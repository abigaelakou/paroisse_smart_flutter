class SessionCatechese {
  final int id;
  final String libSession;

  SessionCatechese({required this.id, required this.libSession});

  factory SessionCatechese.fromJson(Map<String, dynamic> json) {
    return SessionCatechese(
      id: json['id'],
      libSession: json['lib_session_catechese'],
    );
  }
}
