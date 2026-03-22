class CategoryModel {
  final String id;
  final String name;
  final String iconPath;
  final String type;
  final List<CategoryModel> subCategories;

  CategoryModel({
    required this.id,
    required this.name,
    required this.iconPath,
    required this.type,
    this.subCategories = const [],
  });
}

class CategoryData {
  static List<CategoryModel> pemasukan = [
    CategoryModel(
      id: 'gaji',
      name: 'Gaji',
      iconPath: 'assets/icons/lainnya_icon.png',
      type: 'pemasukan',
      subCategories: [
        CategoryModel(
          id: 'upah_jasa',
          name: 'Upah Jasa',
          iconPath: 'assets/icons/order_online.png',
          type: 'pemasukan',
        ),
        CategoryModel(
          id: 'bonus',
          name: 'Bonus',
          iconPath: 'assets/icons/makan_di_warung_resto_icon.png',
          type: 'pemasukan',
        ),
        CategoryModel(
          id: 'gaji_bulanan',
          name: 'Gaji Bulanan',
          iconPath: 'assets/icons/makan_di_warung_resto_icon.png',
          type: 'pemasukan',
        ),
      ],
    ),
    CategoryModel(
      id: 'dividen',
      name: 'Dividen',
      iconPath: 'assets/icons/investasi_icon.png',
      type: 'pemasukan',
      subCategories: [
        CategoryModel(
          id: 'reksadana',
          name: 'Reksadana',
          iconPath: 'assets/icons/reksa_dana.png',
          type: 'pemasukan',
        ),
        CategoryModel(
          id: 'saham',
          name: 'Saham',
          iconPath: 'assets/icons/saham_icon.png',
          type: 'pemasukan',
        ),
        CategoryModel(
          id: 'kripto',
          name: 'Kripto',
          iconPath: 'assets/icons/kripto_icon.png',
          type: 'pemasukan',
        ),
      ],
    ),
    CategoryModel(
      id: 'jual_aset',
      name: 'Jual Aset',
      iconPath: 'assets/icons/jual_asset_icon.png',
      type: 'pemasukan',
    ),
    CategoryModel(
      id: 'pinjaman',
      name: 'Pinjaman',
      iconPath: 'assets/icons/pinjaman_icon.png',
      type: 'pemasukan',
    ),
    CategoryModel(
      id: 'lainnya_masuk',
      name: 'Lainnya',
      iconPath: 'assets/icons/lainnya_icon.png',
      type: 'pemasukan',
    ),
  ];

  static List<CategoryModel> pengeluaran = [
    CategoryModel(
      id: 'makanan',
      name: 'Makanan',
      iconPath: 'assets/icons/makanan_icon.png',
      type: 'pengeluaran',
      subCategories: [
        CategoryModel(
          id: 'order_online',
          name: 'Order Online',
          iconPath: 'assets/icons/order_online.png',
          type: 'pengeluaran',
        ),
        CategoryModel(
          id: 'makan_warung',
          name: 'Makan di Warung/Resto',
          iconPath: 'assets/icons/makan_di_warung_resto_icon.png',
          type: 'pengeluaran',
        ),
      ],
    ),
    CategoryModel(
      id: 'belanja',
      name: 'Belanja',
      iconPath: 'assets/icons/belanja_icon.png',
      type: 'pengeluaran',
      subCategories: [
        CategoryModel(
          id: 'belanja_online',
          name: 'Belanja Online',
          iconPath: 'assets/icons/belanja_online_icon.png',
          type: 'pengeluaran',
        ),
        CategoryModel(
          id: 'belanja_rumah',
          name: 'Belanja Kebutuhan Rumah',
          iconPath: 'assets/icons/belanja_kebutuhan_rumah_icon.png',
          type: 'pengeluaran',
        ),
        CategoryModel(
          id: 'baju',
          name: 'Baju',
          iconPath: 'assets/icons/baju_icon.png',
          type: 'pengeluaran',
        ),
      ],
    ),
    CategoryModel(
      id: 'transport',
      name: 'Transport',
      iconPath: 'assets/icons/transport_icon.png',
      type: 'pengeluaran',
      subCategories: [
        CategoryModel(
          id: 'bensin',
          name: 'Bensin',
          iconPath: 'assets/icons/bensin_icon.png',
          type: 'pengeluaran',
        ),
        CategoryModel(
          id: 'parkir',
          name: 'Parkir',
          iconPath: 'assets/icons/parkir_icon.png',
          type: 'pengeluaran',
        ),
        CategoryModel(
          id: 'transportasi_umum',
          name: 'Transportasi Umum',
          iconPath: 'assets/icons/transportasi_umum_icon.png',
          type: 'pengeluaran',
        ),
      ],
    ),
    CategoryModel(
      id: 'tagihan',
      name: 'Tagihan',
      iconPath: 'assets/icons/tagihan_icon.png',
      type: 'pengeluaran',
      subCategories: [
        CategoryModel(
          id: 'air',
          name: 'Air',
          iconPath: 'assets/icons/air_icon.png',
          type: 'pengeluaran',
        ),
        CategoryModel(
          id: 'internet',
          name: 'Internet',
          iconPath: 'assets/icons/internet_icon.png',
          type: 'pengeluaran',
        ),
        CategoryModel(
          id: 'gas',
          name: 'Gas',
          iconPath: 'assets/icons/gas_icon.png',
          type: 'pengeluaran',
        ),
        CategoryModel(
          id: 'pulsa',
          name: 'Pulsa & Paket Data',
          iconPath: 'assets/icons/pulsa&paket_data_icon.png',
          type: 'pengeluaran',
        ),
      ],
    ),
    CategoryModel(
      id: 'kesehatan',
      name: 'Kesehatan',
      iconPath: 'assets/icons/kesehatan_icon.png',
      type: 'pengeluaran',
    ),
    CategoryModel(
      id: 'pendidikan',
      name: 'Pendidikan',
      iconPath: 'assets/icons/pendidikan_icon.png',
      type: 'pengeluaran',
    ),
    CategoryModel(
      id: 'hiburan',
      name: 'Hiburan',
      iconPath: 'assets/icons/hiburan_icon.png',
      type: 'pengeluaran',
    ),
    CategoryModel(
      id: 'sedekah',
      name: 'Sedekah',
      iconPath: 'assets/icons/sedekah_icon.png',
      type: 'pengeluaran',
    ),
    CategoryModel(
      id: 'service',
      name: 'Service',
      iconPath: 'assets/icons/service_icon.png',
      type: 'pengeluaran',
    ),
    CategoryModel(
      id: 'kartu_kredit',
      name: 'Kartu Kredit',
      iconPath: 'assets/icons/kartu_kredit_icon.png',
      type: 'pengeluaran',
    ),
    CategoryModel(
      id: 'lainnya',
      name: 'Lainnya',
      iconPath: 'assets/icons/lainnya_icon.png',
      type: 'pengeluaran',
    ),
  ];
}
