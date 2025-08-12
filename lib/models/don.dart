class Don {
  final int id;
  final String? description;
  final String modePaiement;
  final double montant;
  final String contact;
  final String dateDon;
  final String paymentStatus;
  final int idTypeDon;
  final String? transactionId;
  final bool anonyme;
  final int paroisseId;

  Don({
    required this.id,
    this.description,
    required this.modePaiement,
    required this.montant,
    required this.contact,
    required this.dateDon,
    required this.paymentStatus,
    required this.idTypeDon,
    this.transactionId,
    required this.anonyme,
    required this.paroisseId,
  });

  factory Don.fromJson(Map<String, dynamic> json) {
    return Don(
      id: json['id'],
      description: json['description'],
      modePaiement: json['mode_paiement'],
      montant: double.tryParse(json['montant'].toString()) ?? 0.0,
      contact: json['contact'] ?? '',
      dateDon: json['date_don'],
      paymentStatus: json['payment_status'],
      idTypeDon: json['id_type_don'],
      transactionId: json['transaction_id'],
      anonyme: json['anonyme'] != null && json['anonyme'] == 1,
      paroisseId: json['paroisse_id'],
    );
  }
}