// lib/features/lender/presentation/pages/add_listing_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_theme.dart';

final _conditionOptions = [
  {'value': 'new', 'label': 'Baru'},
  {'value': 'good', 'label': 'Baik'},
  {'value': 'fair', 'label': 'Cukup Baik'},
];

final _categoryOptions = [
  {'id': 1, 'label': 'Kamera'},
  {'id': 2, 'label': 'Camping'},
  {'id': 3, 'label': 'Perlengkapan Bayi'},
  {'id': 4, 'label': 'Olahraga'},
  {'id': 5, 'label': 'Drone'},
  {'id': 6, 'label': 'Lainnya'},
];

class AddListingPage extends ConsumerStatefulWidget {
  final String? listingId; // null = create, non-null = edit

  const AddListingPage({super.key, this.listingId});

  @override
  ConsumerState<AddListingPage> createState() => _AddListingPageState();
}

class _AddListingPageState extends ConsumerState<AddListingPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _depositCtrl = TextEditingController();
  final _penaltyCtrl = TextEditingController();
  int? _selectedCategoryId;
  String _selectedCondition = 'good';
  final List<XFile> _images = [];
  bool _isLoading = false;

  bool get isEdit => widget.listingId != null;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _depositCtrl.dispose();
    _penaltyCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage(imageQuality: 80);
    if (files.isNotEmpty) {
      setState(() => _images.addAll(files.take(5 - _images.length)));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih kategori barang'), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _isLoading = true);
    // TODO: Call API to create/update listing
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEdit ? 'Barang berhasil diperbarui!' : 'Barang berhasil ditambahkan!'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Barang' : 'Tambah Barang'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo Picker
              const Text('Foto Barang', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              const Text('Tambahkan hingga 5 foto (foto pertama = cover)', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    // Add button
                    if (_images.length < 5)
                      GestureDetector(
                        onTap: _pickImages,
                        child: Container(
                          width: 100, height: 100,
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.primary, style: BorderStyle.solid),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate_outlined, color: AppColors.primary, size: 28),
                              SizedBox(height: 4),
                              Text('Tambah Foto', style: TextStyle(fontSize: 11, color: AppColors.primary)),
                            ],
                          ),
                        ),
                      ),
                    // Selected images
                    ..._images.asMap().entries.map((e) => Stack(
                      children: [
                        Container(
                          width: 100, height: 100,
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: AppColors.divider,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: const Icon(Icons.image_outlined, size: 40, color: AppColors.textSecondary),
                          ),
                        ),
                        Positioned(
                          top: 4, right: 14,
                          child: GestureDetector(
                            onTap: () => setState(() => _images.removeAt(e.key)),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                              child: const Icon(Icons.close, size: 14, color: Colors.white),
                            ),
                          ),
                        ),
                        if (e.key == 0)
                          Positioned(
                            bottom: 4, left: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(6)),
                              child: const Text('Cover', style: TextStyle(fontSize: 10, color: Colors.white)),
                            ),
                          ),
                      ],
                    )),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Title
              const _SectionLabel('Nama Barang'),
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(hintText: 'Contoh: Sony A7III + Kit Lens'),
                validator: (v) => (v == null || v.isEmpty) ? 'Nama barang wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              // Category
              const _SectionLabel('Kategori'),
              DropdownButtonFormField<int>(
                value: _selectedCategoryId,
                hint: const Text('Pilih kategori'),
                decoration: const InputDecoration(),
                items: _categoryOptions.map((c) => DropdownMenuItem<int>(
                  value: c['id'] as int,
                  child: Text(c['label'] as String),
                )).toList(),
                onChanged: (v) => setState(() => _selectedCategoryId = v),
              ),
              const SizedBox(height: 16),

              // Description
              const _SectionLabel('Deskripsi'),
              TextFormField(
                controller: _descCtrl,
                maxLines: 4,
                decoration: const InputDecoration(hintText: 'Jelaskan kondisi, kelengkapan, dan cara pakai barang...'),
                validator: (v) => (v == null || v.isEmpty) ? 'Deskripsi wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              // Condition
              const _SectionLabel('Kondisi Barang'),
              Row(
                children: _conditionOptions.map((opt) {
                  final isSelected = _selectedCondition == opt['value'];
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedCondition = opt['value']!),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : AppColors.bgCard,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: isSelected ? AppColors.primary : AppColors.divider),
                        ),
                        child: Text(
                          opt['label']!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Price per day
              const _SectionLabel('Harga Sewa per Hari'),
              TextFormField(
                controller: _priceCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(prefixText: 'Rp ', hintText: '100.000'),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Harga wajib diisi';
                  if (double.tryParse(v.replaceAll('.', '')) == null) return 'Masukkan angka yang valid';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Deposit
              const _SectionLabel('Deposit (opsional)'),
              TextFormField(
                controller: _depositCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(prefixText: 'Rp ', hintText: '500.000'),
              ),
              const SizedBox(height: 16),

              // Penalty per day
              const _SectionLabel('Denda Keterlambatan per Hari'),
              TextFormField(
                controller: _penaltyCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(prefixText: 'Rp ', hintText: '50.000'),
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(isEdit ? 'Simpan Perubahan' : 'Publikasikan Barang'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
    );
  }
}
