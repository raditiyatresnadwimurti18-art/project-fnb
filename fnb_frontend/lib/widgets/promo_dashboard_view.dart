import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/promo_model.dart';
import '../providers/admin_promo_provider.dart';
import '../providers/admin_menu_provider.dart';
import '../models/menu_model.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_theme.dart';

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
      Provider.of<AdminMenuProvider>(context, listen: false).loadMenus();
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

    if (confirm == true) {
      if (!mounted) return;
      final success = await Provider.of<AdminPromoProvider>(context, listen: false).deletePromo(promo.id!);
      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Promo berhasil dihapus')));
      } else {
        final err = Provider.of<AdminPromoProvider>(context, listen: false).errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err ?? 'Gagal menghapus promo')));
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
    final usedQuotaController = TextEditingController(text: promo?.usedQuota.toString() ?? '0');
    final buyQtyController = TextEditingController(text: promo?.buyQty?.toString() ?? '1');
    final freeQtyController = TextEditingController(text: promo?.freeQty?.toString() ?? '1');
    bool applyMultiple = promo?.applyMultiple ?? false;
    bool isActive = promo?.isActive ?? true;

    DateTime startDate = promo?.startDate ?? DateTime.now();
    DateTime endDate = promo?.endDate ?? DateTime.now().add(const Duration(days: 7));

    final menuProvider = Provider.of<AdminMenuProvider>(context, listen: false);
    final allMenus = menuProvider.menus;
    final categories = allMenus.map((e) => e.kategori).toSet().toList();

    int? menuId = promo?.menuId;
    int? freeMenuId = promo?.freeMenuId;

    String? selectedCategoryBuy;
    if (menuId != null) {
      try {
        selectedCategoryBuy = allMenus.firstWhere((e) => e.id == menuId).kategori;
      } catch (_) {}
    }

    String? selectedCategoryFree;
    if (freeMenuId != null) {
      try {
        selectedCategoryFree = allMenus.firstWhere((e) => e.id == freeMenuId).kategori;
      } catch (_) {}
    }

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
                    initialValue: type,
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
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Kategori Menu Yang Dibeli', border: OutlineInputBorder()),
                      value: selectedCategoryBuy,
                      items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (v) => setStateDialog(() {
                        selectedCategoryBuy = v;
                        menuId = null; // reset menu selection
                      }),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(labelText: 'Pilih Menu Yang Dibeli', border: OutlineInputBorder()),
                      value: menuId,
                      items: allMenus.where((m) => m.kategori == selectedCategoryBuy).map((m) => DropdownMenuItem(value: m.id, child: Text(m.namaMenu))).toList(),
                      onChanged: (v) => setStateDialog(() => menuId = v),
                      validator: (v) => v == null ? 'Wajib pilih menu' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: freeQtyController,
                      decoration: const InputDecoration(labelText: 'Gratis Y', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Kategori Menu Gratis', border: OutlineInputBorder()),
                      value: selectedCategoryFree,
                      items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (v) => setStateDialog(() {
                        selectedCategoryFree = v;
                        freeMenuId = null; // reset free menu selection
                      }),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(labelText: 'Pilih Menu Gratis', border: OutlineInputBorder()),
                      value: freeMenuId,
                      items: allMenus.where((m) => m.kategori == selectedCategoryFree).map((m) => DropdownMenuItem(value: m.id, child: Text(m.namaMenu))).toList(),
                      onChanged: (v) => setStateDialog(() => freeMenuId = v),
                      validator: (v) => v == null ? 'Wajib pilih menu gratis' : null,
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
                    decoration: const InputDecoration(labelText: 'Limit Voucher Promo (0 = Unlimited)', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      final limit = int.tryParse(v ?? '0') ?? 0;
                      final used = int.tryParse(usedQuotaController.text) ?? 0;
                      if (limit > 0 && limit < used) {
                        return 'Limit tidak boleh kurang dari kuota terpakai';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: usedQuotaController,
                    decoration: const InputDecoration(labelText: 'Kuota Terpakai', border: OutlineInputBorder()),
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
                    usedQuota: int.tryParse(usedQuotaController.text) ?? 0,
                    isActive: isActive,
                    buyQty: type == 'bogo' ? int.tryParse(buyQtyController.text) ?? 1 : null,
                    freeQty: type == 'bogo' ? int.tryParse(freeQtyController.text) ?? 1 : null,
                    applyMultiple: type == 'bogo' ? applyMultiple : null,
                    menuId: type == 'bogo' ? menuId : null,
                    freeMenuId: type == 'bogo' ? freeMenuId : null,
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
        if (!mounted) return;
        final success = await Provider.of<AdminPromoProvider>(context, listen: false).savePromo(result, isEdit);
        if (!mounted) return;
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Berhasil menyimpan promo')));
        } else {
          final err = Provider.of<AdminPromoProvider>(context, listen: false).errorMessage;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err ?? 'Gagal menyimpan promo')));
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
                          : ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: provider.promos.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final promo = provider.promos[index];
                                String benefit = promo.type == 'discount'
                                    ? (promo.isPercentage ? '${promo.value}%' : _currencyFormat.format(promo.value))
                                    : 'Beli ${promo.buyQty} Gratis ${promo.freeQty}';
                                
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                    border: Border.all(color: AppTheme.border),
                                  ),
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryLight,
                                          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                                        ),
                                        child: const Icon(Icons.discount_outlined, color: AppTheme.primaryColor),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    promo.name,
                                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                                  ),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: promo.isActive ? AppTheme.successLight : AppTheme.errorLight,
                                                    borderRadius: BorderRadius.circular(16),
                                                  ),
                                                  child: Text(
                                                    promo.isActive ? 'Aktif' : 'Tidak Aktif',
                                                    style: TextStyle(
                                                      color: promo.isActive ? AppTheme.success : AppTheme.error,
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              '${promo.type.toUpperCase()} • $benefit',
                                              style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Terpakai: ${promo.usedQuota} / Limit Voucher Promo: ${promo.quota == 0 ? 'Unlimited' : promo.quota}',
                                              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Column(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit_outlined, color: AppTheme.primaryColor),
                                            onPressed: () => _showPromoFormDialog(promo),
                                            tooltip: 'Edit',
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline, color: AppTheme.error),
                                            onPressed: () => _deletePromo(promo),
                                            tooltip: 'Hapus',
                                          ),
                                        ],
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
