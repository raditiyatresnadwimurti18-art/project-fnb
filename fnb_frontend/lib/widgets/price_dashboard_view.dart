import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/menu_model.dart';
import '../models/price_history_model.dart';
import '../providers/admin_price_provider.dart';
import 'package:intl/intl.dart';

class PriceDashboardView extends StatefulWidget {
  const PriceDashboardView({super.key});

  @override
  State<PriceDashboardView> createState() => _PriceDashboardViewState();
}

class _PriceDashboardViewState extends State<PriceDashboardView> {
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminPriceProvider>(context, listen: false).loadMenus();
    });
  }

  Future<void> _showAddPriceDialog(AdminPriceProvider provider) async {
    if (provider.selectedMenu == null) return;
    final formKey = GlobalKey<FormState>();
    final hargaController = TextEditingController();
    DateTime effectiveDate = DateTime.now();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Tambah Harga Baru'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Menu: ${provider.selectedMenu!.namaMenu}'),
                const SizedBox(height: 12),
                TextFormField(
                  controller: hargaController,
                  decoration: const InputDecoration(labelText: 'Harga Baru', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final newPrice = PriceHistoryModel(
                    menuId: provider.selectedMenu!.id!,
                    newPrice: double.tryParse(hargaController.text) ?? 0,
                    effectiveDate: effectiveDate,
                  );
                  Navigator.pop(context, newPrice);
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    ).then((result) async {
      if (result != null && result is PriceHistoryModel) {
        final success = await provider.addPrice(result);
        if (mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Berhasil menambah harga')));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.errorMessage ?? 'Gagal menambah harga')));
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminPriceProvider>(
      builder: (context, provider, child) {
        return Container(
          color: Colors.grey.shade50,
          padding: EdgeInsets.all(MediaQuery.of(context).size.width > 600 ? 24.0 : 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Manajemen Harga & Histori',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: MediaQuery.of(context).size.width > 800
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // List Menu
                    Expanded(
                      flex: 1,
                      child: Card(
                        child: provider.isLoadingMenus
                            ? const Center(child: CircularProgressIndicator())
                            : ListView.builder(
                                itemCount: provider.menus.length,
                                itemBuilder: (context, index) {
                                  final menu = provider.menus[index];
                                  return ListTile(
                                    selected: provider.selectedMenu?.id == menu.id,
                                    selectedTileColor: Colors.blue.shade50,
                                    title: Text(menu.namaMenu, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    subtitle: Text('Harga Saat Ini: ${_currencyFormat.format(menu.price)}'),
                                    onTap: () => provider.selectMenuAndLoadPrices(menu),
                                  );
                                },
                              ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    // Price History List
                    Expanded(
                      flex: 2,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: provider.selectedMenu == null
                              ? const Center(child: Text('Pilih menu di samping untuk melihat histori harga'))
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Histori Harga: ${provider.selectedMenu!.namaMenu}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                        ElevatedButton.icon(
                                          onPressed: () => _showAddPriceDialog(provider),
                                          icon: const Icon(Icons.add),
                                          label: const Text('Update Harga'),
                                        )
                                      ],
                                    ),
                                    const Divider(height: 30),
                                    Expanded(
                                      child: provider.isLoadingPrices
                                          ? const Center(child: CircularProgressIndicator())
                                          : provider.priceHistories.isEmpty
                                              ? const Center(child: Text('Belum ada histori harga untuk menu ini'))
                                              : ListView.builder(
                                                  itemCount: provider.priceHistories.length,
                                                  itemBuilder: (context, index) {
                                                    final ph = provider.priceHistories[index];
                                                    return ListTile(
                                                      leading: const Icon(Icons.history),
                                                      title: Text('Harga: ${_currencyFormat.format(ph.newPrice)}'),
                                                      subtitle: Text('Efektif: ${DateFormat('dd MMM yyyy HH:mm').format(ph.effectiveDate)}'),
                                                    );
                                                  },
                                                ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                      ],
                    )
                  : Column(
                      children: [
                        // List Menu
                        SizedBox(
                          height: 200,
                          child: Card(
                            child: provider.isLoadingMenus
                                ? const Center(child: CircularProgressIndicator())
                                : ListView.builder(
                                    itemCount: provider.menus.length,
                                    itemBuilder: (context, index) {
                                      final menu = provider.menus[index];
                                      return ListTile(
                                        selected: provider.selectedMenu?.id == menu.id,
                                        selectedTileColor: Colors.blue.shade50,
                                        title: Text(menu.namaMenu, style: const TextStyle(fontWeight: FontWeight.bold)),
                                        subtitle: Text('Harga Saat Ini: ${_currencyFormat.format(menu.price)}'),
                                        onTap: () => provider.selectMenuAndLoadPrices(menu),
                                      );
                                    },
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Price History List
                        Expanded(
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: provider.selectedMenu == null
                                  ? const Center(child: Text('Pilih menu di atas'))
                                  : Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(child: Text('Histori: ${provider.selectedMenu!.namaMenu}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                                            ElevatedButton.icon(
                                              onPressed: () => _showAddPriceDialog(provider),
                                              icon: const Icon(Icons.add, size: 16),
                                              label: const Text('Update'),
                                            )
                                          ],
                                        ),
                                        const Divider(height: 30),
                                        Expanded(
                                          child: provider.isLoadingPrices
                                              ? const Center(child: CircularProgressIndicator())
                                              : provider.priceHistories.isEmpty
                                                  ? const Center(child: Text('Belum ada histori'))
                                                  : ListView.builder(
                                                      itemCount: provider.priceHistories.length,
                                                      itemBuilder: (context, index) {
                                                        final ph = provider.priceHistories[index];
                                                        return ListTile(
                                                          leading: const Icon(Icons.history),
                                                          title: Text('Harga: ${_currencyFormat.format(ph.newPrice)}'),
                                                          subtitle: Text('Efektif: ${DateFormat('dd MMM yyyy HH:mm').format(ph.effectiveDate)}'),
                                                        );
                                                      },
                                                    ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
              )
            ],
          ),
        );
      }
    );
  }
}
