import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';
import 'package:image_picker/image_picker.dart';

class TransactionController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final RxString nominalDisplay = '0'.obs;
  final RxDouble nominalValue = 0.0.obs;
  final RxString deskripsi = ''.obs;
  final Rx<DateTime> tanggal = DateTime.now().obs;
  final Rx<CategoryModel?> selectedCategory = Rx<CategoryModel?>(null);
  final RxBool isLoading = false.obs;

  final ImagePicker _picker = ImagePicker();
  final RxList<XFile> receiptImages = <XFile>[].obs;

  String _rawInput = '';

  void selectCategory(CategoryModel category) {
    selectedCategory.value = category;
  }

  void onNumpadTap(String key) {
    switch (key) {
      case 'C':
        _rawInput = '';
        nominalDisplay.value = '0';
        nominalValue.value = 0;
        break;
      case '⌫':
        if (_rawInput.isNotEmpty) {
          _rawInput = _rawInput.substring(0, _rawInput.length - 1);
          _updateNominal();
        }
        break;
      case '0':
        if (_rawInput.isNotEmpty) {
          _rawInput += '0';
          _updateNominal();
        }
        break;
      case '00':
        if (_rawInput.isNotEmpty) {
          _rawInput += '00';
          _updateNominal();
        }
        break;
      case '000':
        if (_rawInput.isNotEmpty) {
          _rawInput += '000';
          _updateNominal();
        }
        break;
      case 'OK':
        break;
      case '÷':
      case '+':
      case '-':
      case '=':
        break;
      default:
        if (_rawInput.length < 12) {
          _rawInput += key;
          _updateNominal();
        }
    }
  }

  void _updateNominal() {
    if (_rawInput.isEmpty) {
      nominalDisplay.value = '0';
      nominalValue.value = 0;
    } else {
      final value = double.tryParse(_rawInput) ?? 0;
      nominalValue.value = value;
      nominalDisplay.value = _formatRupiah(value.toInt());
    }
  }

  String _formatRupiah(int value) {
    final str = value.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(str[i]);
      count++;
    }
    return buffer.toString().split('').reversed.join('');
  }

  String get formattedTanggal {
    final months = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${tanggal.value.day} ${months[tanggal.value.month]} ${tanggal.value.year}';
  }

  bool validate() {
    if (selectedCategory.value == null) {
      Get.snackbar(
        'Peringatan',
        'Pilih kategori terlebih dahulu',
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade800,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }
    if (nominalValue.value <= 0) {
      Get.snackbar(
        'Peringatan',
        'Masukkan nominal yang valid',
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade800,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }
    return true;
  }

  Future<void> pickReceipts() async {
    try {
      final List<XFile>? picked = await _picker.pickMultiImage(
        imageQuality: 70,
      );
      if (picked != null && picked.isNotEmpty) {
        final newList = List<XFile>.from(receiptImages);
        newList.addAll(picked);
        if (newList.length > 5) {
          receiptImages.value = newList.sublist(0, 5);
        } else {
          receiptImages.value = newList;
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memilih foto: $e');
    }
  }

  Future<void> replaceReceipt(int index) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      if (picked != null) {
        final newList = List<XFile>.from(receiptImages);
        if (index >= 0 && index < newList.length) {
          newList[index] = picked;
          receiptImages.value = newList;
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengganti foto: $e');
    }
  }

  void removeReceipt(int index) {
    final newList = List<XFile>.from(receiptImages);
    if (index >= 0 && index < newList.length) {
      newList.removeAt(index);
      receiptImages.value = newList;
    }
  }

  Future<String> _compressImage(XFile xfile) async {
    final dir = await getTemporaryDirectory();
    final targetPath =
        '${dir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}_${xfile.name}';
    final result = await FlutterImageCompress.compressAndGetFile(
      xfile.path,
      targetPath,
      quality: 80,
    );
    return result?.path ?? xfile.path;
  }

  Future<bool> saveTransaction(String type) async {
    if (!validate()) return false;

    isLoading.value = true;
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User tidak ditemukan');

      final List<String> compressedPaths = [];
      for (final xfile in receiptImages) {
        final compressedPath = await _compressImage(xfile);
        compressedPaths.add(compressedPath);
      }

      final tx = TransactionModel(
        type: type,
        categoryId: selectedCategory.value!.id,
        categoryName: selectedCategory.value!.name,
        categoryIconPath: selectedCategory.value!.iconPath,
        nominal: nominalValue.value,
        deskripsi: deskripsi.value,
        tanggal: tanggal.value,
        userId: user.uid,
        receiptPaths: compressedPaths,
      );

      await _firestore.collection('transactions').add(tx.toMap());
      _resetForm();
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menyimpan transaksi: $e',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void _resetForm() {
    _rawInput = '';
    nominalDisplay.value = '0';
    nominalValue.value = 0;
    deskripsi.value = '';
    tanggal.value = DateTime.now();
    selectedCategory.value = null;
    receiptImages.value = [];
  }
}
