import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String? id;
  final String type;
  final String categoryId;
  final String categoryName;
  final String categoryIconPath;
  final double nominal;
  final String deskripsi;
  final DateTime tanggal;
  final String userId;
  final List<String> receiptPaths;

  TransactionModel({
    this.id,
    required this.type,
    required this.categoryId,
    required this.categoryName,
    required this.categoryIconPath,
    required this.nominal,
    this.deskripsi = '',
    required this.tanggal,
    required this.userId,
    this.receiptPaths = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'categoryIconPath': categoryIconPath,
      'nominal': nominal,
      'deskripsi': deskripsi,
      'tanggal': Timestamp.fromDate(tanggal),
      'userId': userId,
      'receiptPaths': receiptPaths,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map, String docId) {
    return TransactionModel(
      id: docId,
      type: map['type'] ?? '',
      categoryId: map['categoryId'] ?? '',
      categoryName: map['categoryName'] ?? '',
      categoryIconPath: map['categoryIconPath'] ?? '',
      nominal: (map['nominal'] as num).toDouble(),
      deskripsi: map['deskripsi'] ?? '',
      tanggal: (map['tanggal'] as Timestamp).toDate(),
      userId: map['userId'] ?? '',
      receiptPaths: List<String>.from(map['receiptPaths'] ?? []),
    );
  }
}
