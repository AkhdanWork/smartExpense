import 'package:flutter/material.dart';

class CategoryStyle {
  static const Map<String, Color> _colors = {
    'makanan': Color(0xFFFF6B35),
    'order_online': Color(0xFFFF6B35),
    'makan_warung': Color(0xFFFF8C42),
    'belanja': Color(0xFF9B59B6),
    'belanja_online': Color(0xFFAB69C6),
    'belanja_rumah': Color(0xFF8E44AD),
    'baju': Color(0xFFBD7FC4),
    'transport': Color(0xFF3498DB),
    'bensin': Color(0xFF2980B9),
    'parkir': Color(0xFF5DADE2),
    'transportasi_umum': Color(0xFF1A78C2),
    'tagihan': Color(0xFF1ABC9C),
    'air': Color(0xFF48C9B0),
    'internet': Color(0xFF17A589),
    'gas': Color(0xFF45B39D),
    'pulsa': Color(0xFF0EAD9A),
    'kesehatan': Color(0xFFE74C3C),
    'pendidikan': Color(0xFF2ECC71),
    'hiburan': Color(0xFFF39C12),
    'sedekah': Color(0xFF27AE60),
    'service': Color(0xFF7F8C8D),
    'kartu_kredit': Color(0xFF2C3E50),
    'lainnya': Color(0xFF95A5A6),

    'gaji': Color(0xFF27AE60),
    'upah_jasa': Color(0xFF2ECC71),
    'bonus': Color(0xFF1ABC9C),
    'gaji_bulanan': Color(0xFF16A085),
    'dividen': Color(0xFFF39C12),
    'reksadana': Color(0xFFE67E22),
    'saham': Color(0xFFD35400),
    'kripto': Color(0xFF8E44AD),
    'jual_aset': Color(0xFF3498DB),
    'pinjaman': Color(0xFFE74C3C),
    'order_online_masuk': Color(0xFFFF6B35),
    'lainnya_masuk': Color(0xFF95A5A6),
  };

  static Color colorById(String id) => _colors[id] ?? const Color(0xFF95A5A6);

  static Color colorByName(String name) {
    final normalized = name
        .toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll('/', '_');
    if (_colors.containsKey(normalized)) return _colors[normalized]!;
    for (final entry in _colors.entries) {
      if (normalized.contains(entry.key) || entry.key.contains(normalized)) {
        return entry.value;
      }
    }
    return const Color(0xFF95A5A6);
  }

  static Widget iconBox(
    String iconPath,
    String categoryId, {
    double size = 40,
    Color? overrideColor,
  }) {
    final color = overrideColor ?? colorById(categoryId);
    final padding = size * 0.22;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      padding: EdgeInsets.all(padding),
      child: Image.asset(
        iconPath,
        fit: BoxFit.contain,
        color: Colors.white,
        errorBuilder: (_, __, ___) =>
            Icon(Icons.category, color: Colors.white, size: size * 0.55),
      ),
    );
  }

  static Widget iconBoxByName(
    String iconPath,
    String categoryName, {
    double size = 40,
  }) {
    return iconBox(
      iconPath,
      '',
      size: size,
      overrideColor: colorByName(categoryName),
    );
  }
}
