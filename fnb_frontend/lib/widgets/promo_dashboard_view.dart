import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/promo_model.dart';
import '../providers/admin_promo_provider.dart';
import 'package:intl/intl.dart';

class PromoDashboardView extends StatefulWidget {
  const PromoDashboardView({super.key});

  @override
  State<PromoDashboardView> createState() => _PromoDashboardViewState();
}

class _PromoDashboardViewState extends State<PromoDashboardView> {
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminPromoProvider>(context, listen: false).loadPromos();
    });
  }

  Future<void> _deletePromo(PromoModel promo) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Promo'),
        content: Text('Anda yakin ingin menghapus promo ${promo.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final success = await Provider.of<AdminPromoProvider>(context, listen: false).deletePromo(promo.id!);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Promo berhasil dihapus')));
        } else {
          final err = Provider.of<AdminPromoProvider>(context, listen: false).errorMessage;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err ?? 'Gagal menghapus promo')));
        }
      }
    }
  }

  Future<void> _showPromoFormDialog([PromoModel? promo]) async {
    final isEdit = promo != null;
    final formKey = GlobalKey<FormState>();
    
    String type = promo?.type ?? 'discount';
    final nameController = TextEditingController(text: promo?.name ?? '');
    final valueController = TextEditingController(text: promo?.value.toString() ?? '0');
    bool isPercentage = promo?.isPercentage ?? false;
    final maxDiscountController = TextEditingController(text: promo?.maxDiscount.toString() ?? '0');
    final minPurchaseController = TextEditingController(text: promo?.minPurchase.toString() ?? '0');
    final quotaController = TextEditingController(text: promo?.quota.toString() ?? '0');
    final buyQtyController = TextEditingController(text: promo?.buyQty?.toString() ?? '1');
    final freeQtyController = TextEditingController(text: promo?.freeQty?.toString() ?? '1');
    bool applyMultiple = promo?.applyMultiple ?? false;
    bool isActive = promo?.isActive ?? true;

    DateTime startDate = promo?.startDate ?? DateTime.now();
    DateTime endDate = promo?.endDate ?? DateTime.now().add(const Duration(days: 7));

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text(isEdit ? 'Edit Promo' : 'Tambah Promo Baru'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nama Promo', border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: type,
                    decoration: const InputDecoration(labelText: 'Tipe Promo', border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 'discount', child: Text('Diskon / Potongan Harga')),
                      DropdownMenuItem(value: 'bogo', child: Text('Buy 1 Get 1 (BOGO)')),
                    ],
                    onChanged: (v) => setStateDialog(() => type = v!),
                  ),
                  const SizedBox(height: 12),
                  
                  if (type == 'discount') ...[
                    SwitchListTile(
                      title: const Text('Diskon Persentase?'),
                      value: isPercentage,
                      onChanged: (v) => setStateDialog(() => isPercentage = v),
                    ),
                    TextFormField(
                      controller: valueController,
                      decoration: InputDecoration(labelText: isPercentage ? 'Persentase Diskon (%)' : 'Nominal Diskon (Rp)', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: maxDiscountController,
                      decoration: const InputDecoration(labelText: 'Maksimal Diskon (Opsional)', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: minPurchaseController,
                      decoration: const InputDecoration(labelText: 'Minimal Pembelian (Opsional)', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                  ] else ...[
                    TextFormField(
                      controller: buyQtyController,
                      decoration: const InputDecoration(labelText: 'Beli X', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: freeQtyController,
                      decoration: const InputDecoration(labelText: 'Gratis Y', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: const Text('Berlaku Kelipatan?'),
                      value: applyMultiple,
                      onChanged: (v) => setStateDialog(() => applyMultiple = v),
                    ),
                  ],

                  const SizedBox(height: 12),
                  TextFormField(
                    controller: quotaController,
                    decoration: const InputDecoration(labelText: 'Kuota Promo (0 = Unlimited)', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('Status Aktif'),
                    value: isActive,
                    onChanged: (v) => setStateDialog(() => isActive = v),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final newPromo = PromoModel(
                    id: promo?.id,
                    name: nameController.text,
                    type: type,
                    value: double.tryParse(valueController.text) ?? 0,
                    isPercentage: isPercentage,
                    maxDiscount: double.tryParse(maxDiscountController.text) ?? 0,
                    minPurchase: double.tryParse(minPurchaseController.text) ?? 0,
                    startDate: startDate,
                    endDate: endDate,
                    quota: int.tryParse(quotaController.text) ?? 0,
                    isActive: isActive,
                    buyQty: type == 'bogo' ? int.tryParse(buyQtyController.text) ?? 1 : null,
                    freeQty: type == 'bogo' ? int.tryParse(freeQtyController.text) ?? 1 : null,
                    applyMultiple: type == 'bogo' ? applyMultiple : null,
                  );
                  Navigator.pop(context, newPromo);
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    ).then((result) async {
      if (result != null && result is PromoModel) {
        final success = await Provider.of<AdminPromoProvider>(context, listen: false).savePromo(result, isEdit);
        if (mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Berhasil menyimpan promo')));
          } else {
            final err = Provider.of<AdminPromoProvider>(context, listen: false).errorMessage;
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err ?? 'Gagal menyimpan promo')));
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminPromoProvider>(
      builder: (context, provider, child) {
        return Container(
          color: Colors.grey.shade50,
          padding: EdgeInsets.all(MediaQuery.of(context).size.width > 600 ? 24.0 : 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Manajemen Promo',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showPromoFormDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah Promo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Card(
                  child: provider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : provider.promos.isEmpty
                          ? const Center(child: Text('Tidak ada promo aktif.'))
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: provider.promos.length,
                              itemBuilder: (context, index) {
                                final promo = provider.promos[index];
                                String benefit = promo.type == 'discount'
                                    ? (promo.isPercentage ? '${promo.value}%' : _currencyFormat.format(promo.value))
                                    : 'Beli ${promo.buyQty} Gratis ${promo.freeQty}';
                                
                                return ListTile(
                                  title: Text(promo.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text('${promo.type.toUpperCase()} - $benefit'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Chip(
                                        label: Text(promo.isActive ? 'Aktif' : 'Tidak Aktif'),
                                        backgroundColor: promo.isActive ? Colors.green.shade100 : Colors.red.shade100,
                                        labelStyle: TextStyle(
                                          color: promo.isActive ? Colors.green.shade800 : Colors.red.shade800,
                                          fontSize: 12,
                                        ),
                                        side: BorderSide.none,
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.blue),
                                        onPressed: () => _showPromoFormDialog(promo),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => _deletePromo(promo),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}
