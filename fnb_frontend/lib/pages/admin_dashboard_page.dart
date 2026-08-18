import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/menu_model.dart';
import '../providers/admin_menu_provider.dart';
import '../widgets/promo_dashboard_view.dart';
import '../widgets/kasir_dashboard_view.dart';
import '../widgets/report_dashboard_view.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/custom_image_view.dart';
import '../models/inventory_model.dart';
import '../repositories/inventory_repository.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _selectedIndex = 0;
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  final InventoryRepository _inventoryRepository = InventoryRepository();
  InventoryOverviewModel? _inventory;
  bool _isInventoryLoading = true;
  bool _activeBatchesOnly = false;
  String? _inventoryError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminMenuProvider>(context, listen: false).loadMenus();
      _loadInventory();
    });
  }

  Future<void> _loadInventory() async {
    if (mounted) {
      setState(() {
        _isInventoryLoading = true;
        _inventoryError = null;
      });
    }

    try {
      final inventory = await _inventoryRepository.getInventory(
        activeOnly: _activeBatchesOnly,
      );
      if (!mounted) return;
      setState(() => _inventory = inventory);
    } catch (e) {
      if (!mounted) return;
      setState(() => _inventoryError = e.toString());
    } finally {
      if (mounted) setState(() => _isInventoryLoading = false);
    }
  }

  Future<void> _showInventoryDetail(InventorySummaryModel inventory) async {
    try {
      final detail = await _inventoryRepository.getInventoryByMenuId(inventory.menuId);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Riwayat FIFO: ${detail.summary.menu.namaMenu}'),
          content: SizedBox(
            width: 640,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sisa stok: ${detail.summary.totalRemaining} dari ${detail.summary.totalPurchased}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text('Rata-rata modal tersisa: ${_currencyFormat.format(detail.summary.avgModal)}'),
                  const SizedBox(height: 16),
                  if (detail.batches.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: Text('Belum ada batch stok.')),
                    )
                  else
                    ...detail.batches.map(
                      (batch) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: batch.qtyRemaining > 0
                                ? AppTheme.success.withValues(alpha: 0.12)
                                : Colors.grey.shade200,
                            child: Icon(
                              batch.qtyRemaining > 0 ? Icons.inventory_2 : Icons.inventory_2_outlined,
                              color: batch.qtyRemaining > 0 ? AppTheme.success : Colors.grey,
                            ),
                          ),
                          title: Text('Batch #${batch.id} • Modal ${_currencyFormat.format(batch.modal)}'),
                          subtitle: Text(
                            'Dibeli ${batch.purchasedAt == null ? '-' : DateFormat('dd MMM yyyy, HH:mm').format(batch.purchasedAt!.toLocal())}',
                          ),
                          trailing: Text(
                            '${batch.qtyRemaining}/${batch.qtyPurchased}\nsisa',
                            textAlign: TextAlign.right,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup')),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat detail inventory: $e')),
      );
    }
  }

  Future<void> _deleteMenu(MenuModel menu) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Menu'),
        content: Text('Anda yakin ingin menghapus ${menu.namaMenu}?'),
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
      final success = await Provider.of<AdminMenuProvider>(context, listen: false).deleteMenu(menu.id!);
      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Menu berhasil dihapus')));
      } else {
        final err = Provider.of<AdminMenuProvider>(context, listen: false).errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err ?? 'Gagal menghapus menu')));
      }
    }
  }

  Future<void> _confirmLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      Provider.of<AuthProvider>(context, listen: false).logout();
    }
  }

  void _showStockDialog(MenuModel menu) {
    final qtyController = TextEditingController();
    final modalController = TextEditingController();
    bool isAddStock = true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text('Kelola Stok: ${menu.namaMenu}'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<bool>(
                            title: const Text('Tambah Stok'),
                            value: true,
                            groupValue: isAddStock,
                            onChanged: (val) => setStateDialog(() => isAddStock = val!),
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<bool>(
                            title: const Text('Kurangi Stok'),
                            value: false,
                            groupValue: isAddStock,
                            onChanged: (val) => setStateDialog(() => isAddStock = val!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: qtyController,
                      decoration: const InputDecoration(labelText: 'Jumlah (Qty)'),
                      keyboardType: TextInputType.number,
                    ),
                    if (isAddStock) ...[
                      const SizedBox(height: 16),
                      TextField(
                        controller: modalController,
                        decoration: const InputDecoration(labelText: 'Harga Modal (per satuan)'),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final qty = int.tryParse(qtyController.text) ?? 0;
                    if (qty <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Qty harus lebih dari 0')));
                      return;
                    }

                    final provider = context.read<AdminMenuProvider>();
                    bool success = false;

                    if (isAddStock) {
                      final modal = double.tryParse(modalController.text) ?? 0;
                      if (modal <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Modal harus lebih dari 0')));
                        return;
                      }
                      success = await provider.addStock(menu.id!, qty, modal);
                    } else {
                      success = await provider.adjustStock(menu.id!, qty);
                    }

                    if (context.mounted) {
                      if (success) {
                        Navigator.pop(context);
                        _loadInventory();
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Stok berhasil diupdate')));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.errorMessage ?? 'Gagal update stok')));
                      }
                    }
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showMenuFormDialog([MenuModel? menu]) async {
    final isEdit = menu != null;
    final formKey = GlobalKey<FormState>();
    final namaController = TextEditingController(text: menu?.namaMenu ?? '');
    
    final List<String> kategoriOptions = ['Makanan', 'Minuman', 'Desert', 'Coffee'];
    String selectedKategori = menu?.kategori ?? 'Makanan';
    if (!kategoriOptions.contains(selectedKategori)) selectedKategori = 'Makanan';


    final hargaController = TextEditingController(text: menu?.price.toString() ?? '');
    final deskripsiController = TextEditingController(text: menu?.deskripsi ?? '');
    final gambarController = TextEditingController(text: menu?.gambar ?? '');
    bool isActive = menu?.isActive ?? true;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text(isEdit ? 'Edit Menu' : 'Tambah Menu Baru'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: namaController,
                    decoration: const InputDecoration(labelText: 'Nama Menu *'),
                    validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: selectedKategori,
                    decoration: const InputDecoration(labelText: 'Kategori *'),
                    items: kategoriOptions.map((String cat) {
                      return DropdownMenuItem<String>(
                        value: cat,
                        child: Text(cat),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setStateDialog(() => selectedKategori = val);
                      }
                    },
                  ),
                  TextFormField(
                    controller: hargaController,
                    decoration: const InputDecoration(labelText: 'Harga Jual *'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  TextFormField(
                    controller: deskripsiController,
                    decoration: const InputDecoration(labelText: 'Deskripsi'),
                    maxLines: 3,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: gambarController,
                          decoration: const InputDecoration(labelText: 'URL Gambar / File'),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.upload_file, color: AppTheme.primaryColor),
                        tooltip: 'Upload Gambar Lokal',
                        onPressed: () async {
                          final picker = ImagePicker();
                          final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
                          if (image != null) {
                            final bytes = await image.readAsBytes();
                            final base64String = base64Encode(bytes);
                            gambarController.text = base64String;
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final newMenu = MenuModel(
                    id: menu?.id,
                    kodeMenu: menu?.kodeMenu ?? '',
                    namaMenu: namaController.text,
                    kategori: selectedKategori,
                    modal: 0, // modal tidak lagi diset saat create/update menu
                    price: double.tryParse(hargaController.text) ?? 0,
                    deskripsi: deskripsiController.text,
                    gambar: gambarController.text,
                    isActive: isActive,
                  );
                  Navigator.pop(context, newMenu);
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    ).then((result) async {
      if (result != null && result is MenuModel) {
        if (!mounted) return;
        final success = await Provider.of<AdminMenuProvider>(context, listen: false).saveMenu(result, isEdit);
        if (!mounted) return;
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Berhasil menyimpan menu')));
        } else {
          final err = Provider.of<AdminMenuProvider>(context, listen: false).errorMessage;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err ?? 'Gagal menyimpan menu')));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            // Navigation Rail
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (int index) {
                if (index == 5) {
                  _confirmLogout();
                } else {
                  setState(() {
                    _selectedIndex = index;
                  });
                }
              },
              labelType: NavigationRailLabelType.all,
              backgroundColor: Colors.white,
              elevation: 2,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.restaurant_menu_outlined),
                  selectedIcon: Icon(Icons.restaurant_menu),
                  label: Text('Menu'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.discount_outlined),
                  selectedIcon: Icon(Icons.discount),
                  label: Text('Promo'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.people_outline),
                  selectedIcon: Icon(Icons.people),
                  label: Text('Kasir'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.inventory_2_outlined),
                  selectedIcon: Icon(Icons.inventory_2),
                  label: Text('Inventory'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.analytics_outlined),
                  selectedIcon: Icon(Icons.analytics),
                  label: Text('Laporan'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.logout, color: Colors.red),
                  selectedIcon: Icon(Icons.logout, color: Colors.red),
                  label: Text('Logout', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
            // Main Content Area
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard', style: TextStyle(fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            tooltip: 'Logout',
            onPressed: _confirmLogout,
          )
        ],
      ),
      body: _buildContent(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            selectedIcon: Icon(Icons.restaurant_menu),
            label: 'Menu',
          ),
          NavigationDestination(
            icon: Icon(Icons.discount_outlined),
            selectedIcon: Icon(Icons.discount),
            label: 'Promo',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Kasir',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Inventory',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: 'Laporan',
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_selectedIndex == 0) {
      return _buildMenuManagement();
    } else if (_selectedIndex == 1) {
      return const PromoDashboardView();
    } else if (_selectedIndex == 2) {
      return const KasirDashboardView();
    } else if (_selectedIndex == 3) {
      return _buildInventoryManagement();
    } else if (_selectedIndex == 4) {
      return const ReportDashboardView();
    } else {
      return Center(
        child: Text(
          'Halaman belum diimplementasikan.',
          style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
        ),
      );
    }
  }

  Widget _buildInventoryManagement() {
    final inventory = _inventory;
    return Container(
      color: Colors.grey.shade50,
      padding: EdgeInsets.all(MediaQuery.of(context).size.width > 600 ? 24 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text('Inventory', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              FilterChip(
                label: const Text('Batch aktif saja'),
                selected: _activeBatchesOnly,
                onSelected: (selected) {
                  setState(() => _activeBatchesOnly = selected);
                  _loadInventory();
                },
              ),
              OutlinedButton.icon(
                onPressed: _isInventoryLoading ? null : _loadInventory,
                icon: const Icon(Icons.refresh),
                label: const Text('Muat ulang'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _isInventoryLoading
                ? const Center(child: CircularProgressIndicator())
                : _inventoryError != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline, color: AppTheme.error, size: 48),
                            const SizedBox(height: 12),
                            Text(_inventoryError!, textAlign: TextAlign.center),
                            const SizedBox(height: 12),
                            ElevatedButton(onPressed: _loadInventory, child: const Text('Coba lagi')),
                          ],
                        ),
                      )
                    : inventory == null || inventory.summary.isEmpty
                        ? const Center(child: Text('Belum ada data inventory.'))
                        : ListView(
                            children: [
                              Wrap(
                                spacing: 16,
                                runSpacing: 16,
                                children: [
                                  _inventoryMetric('Total Menu', inventory.summary.length.toString(), Icons.restaurant_menu),
                                  _inventoryMetric('Stok Tersisa', inventory.summary.fold<int>(0, (total, item) => total + item.totalRemaining).toString(), Icons.inventory),
                                  _inventoryMetric('Batch Aktif', inventory.summary.fold<int>(0, (total, item) => total + item.activeBatchCount).toString(), Icons.layers_outlined),
                                ],
                              ),
                              const SizedBox(height: 28),
                              const Text('Ringkasan per Menu', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 12),
                              Card(
                                child: ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: inventory.summary.length,
                                  separatorBuilder: (_, __) => const Divider(height: 1),
                                  itemBuilder: (context, index) {
                                    final item = inventory.summary[index];
                                    return ListTile(
                                      leading: CircleAvatar(child: Text(item.totalRemaining.toString())),
                                      title: Text(item.menu.namaMenu, style: const TextStyle(fontWeight: FontWeight.bold)),
                                      subtitle: Text('${item.menu.kategori} • ${item.activeBatchCount}/${item.batchCount} batch aktif\nModal rata-rata: ${_currencyFormat.format(item.avgModal)}'),
                                      isThreeLine: true,
                                      trailing: TextButton.icon(
                                        onPressed: () => _showInventoryDetail(item),
                                        icon: const Icon(Icons.history),
                                        label: const Text('FIFO'),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
          ),
        ],
      ),
    );
  }

  Widget _inventoryMetric(String title, String value, IconData icon) {
    return Container(
      width: 190,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuManagement() {
    return Consumer<AdminMenuProvider>(
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
                    'Manajemen Menu',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showMenuFormDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah Menu'),
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
                      : provider.menus.isEmpty
                          ? const Center(child: Text('Tidak ada data menu.'))
                          : GridView.builder(
                              padding: const EdgeInsets.all(16),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 4 : (MediaQuery.of(context).size.width > 800 ? 3 : (MediaQuery.of(context).size.width > 600 ? 2 : 1)),
                                childAspectRatio: 3 / 1,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                mainAxisExtent: 110,
                              ),
                              itemCount: provider.menus.length,
                              itemBuilder: (context, index) {
                                final menu = provider.menus[index];
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                    border: Border.all(color: AppTheme.border),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 80,
                                        height: double.infinity,
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(AppTheme.radiusMedium),
                                            bottomLeft: Radius.circular(AppTheme.radiusMedium),
                                          ),
                                          color: AppTheme.background,
                                        ),
                                        child: ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(AppTheme.radiusMedium),
                                            bottomLeft: Radius.circular(AppTheme.radiusMedium),
                                          ),
                                          child: CustomImageView(
                                            imageString: menu.gambar,
                                            fit: BoxFit.cover,
                                            fallback: const Icon(Icons.fastfood, color: AppTheme.textHint),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                menu.namaMenu,
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${menu.kategori} • ${_currencyFormat.format(menu.price)}',
                                                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Stok: ${menu.totalStock} - ${menu.isActive ? "Tersedia" : "Habis"}',
                                                style: TextStyle(color: menu.isActive ? Colors.green : Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            height: 32,
                                            child: IconButton(
                                              icon: const Icon(Icons.inventory_2_outlined, color: Colors.blue, size: 18),
                                              onPressed: () => _showStockDialog(menu),
                                              tooltip: 'Kelola Stok',
                                            ),
                                          ),
                                          SizedBox(
                                            height: 32,
                                            child: IconButton(
                                              icon: const Icon(Icons.edit_outlined, color: AppTheme.primaryColor, size: 18),
                                              onPressed: () => _showMenuFormDialog(menu),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 32,
                                            child: IconButton(
                                              icon: const Icon(Icons.delete_outline, color: AppTheme.error, size: 18),
                                              onPressed: () => _deleteMenu(menu),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 8),
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
      },
    );
  }
}
