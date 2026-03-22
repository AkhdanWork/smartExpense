import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_expense/helpers/category_style.dart';
import '../models/category_model.dart';

class CategoryPickerPage extends StatefulWidget {
  final String type;
  const CategoryPickerPage({super.key, required this.type});

  @override
  State<CategoryPickerPage> createState() => _CategoryPickerPageState();
}

class _CategoryPickerPageState extends State<CategoryPickerPage> {
  String _searchQuery = '';
  late List<CategoryModel> _allCategories;

  final Set<String> _expandedIds = {};

  @override
  void initState() {
    super.initState();
    _allCategories = widget.type == 'pemasukan'
        ? CategoryData.pemasukan
        : CategoryData.pengeluaran;
  }

  List<CategoryModel> get _filtered {
    if (_searchQuery.isEmpty) return _allCategories;
    final q = _searchQuery.toLowerCase();
    final result = <CategoryModel>[];
    for (final cat in _allCategories) {
      if (cat.name.toLowerCase().contains(q)) {
        result.add(cat);
      } else {
        final matchingSubs = cat.subCategories
            .where((s) => s.name.toLowerCase().contains(q))
            .toList();
        if (matchingSubs.isNotEmpty) {
          result.add(
            CategoryModel(
              id: cat.id,
              name: cat.name,
              iconPath: cat.iconPath,
              type: cat.type,
              subCategories: matchingSubs,
            ),
          );
        }
      }
    }
    return result;
  }

  void _selectCategory(CategoryModel cat) => Get.back(result: cat);

  void _toggleExpand(String id) {
    setState(() {
      if (_expandedIds.contains(id)) {
        _expandedIds.remove(id);
      } else {
        _expandedIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    if (_searchQuery.isNotEmpty) {
      for (final cat in filtered) {
        if (cat.subCategories.isNotEmpty) _expandedIds.add(cat.id);
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Pilih Kategori',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF3F3F3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: const InputDecoration(
                  hintText: 'Cari Kategori',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),

          const Padding(
            padding: EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Daftar Kategori',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ),
          ),

          const Divider(height: 1, color: Color(0xFFEEEEEE)),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 24),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final cat = filtered[index];
                final hasChildren = cat.subCategories.isNotEmpty;
                final isExpanded = _expandedIds.contains(cat.id);

                return Column(
                  children: [
                    InkWell(
                      onTap: hasChildren
                          ? () => _toggleExpand(cat.id)
                          : () => _selectCategory(cat),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            CategoryStyle.iconBox(
                              cat.iconPath,
                              cat.id,
                              size: 40,
                            ),
                            const SizedBox(width: 14),

                            Expanded(
                              child: Text(
                                cat.name,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),

                            if (hasChildren) ...[
                              if (cat.subCategories.length > 1)
                                Container(
                                  margin: const EdgeInsets.only(right: 6),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF0F0F0),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${cat.subCategories.length}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black45,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              Icon(
                                isExpanded
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                color: Colors.black38,
                                size: 22,
                              ),
                            ] else
                              const Icon(
                                Icons.chevron_right,
                                color: Colors.black26,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    ),

                    if (hasChildren && isExpanded)
                      Container(
                        color: const Color(0xFFFAFAFA),
                        child: Column(
                          children: cat.subCategories.map((sub) {
                            return InkWell(
                              onTap: () => _selectCategory(sub),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 32,
                                  right: 16,
                                  top: 10,
                                  bottom: 10,
                                ),
                                child: Row(
                                  children: [
                                    CategoryStyle.iconBox(
                                      sub.iconPath,
                                      sub.id,
                                      size: 34,
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Text(
                                        sub.name,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.chevron_right,
                                      color: Colors.black26,
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                    const Divider(
                      height: 1,
                      color: Color(0xFFEEEEEE),
                      indent: 16,
                      endIndent: 16,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
