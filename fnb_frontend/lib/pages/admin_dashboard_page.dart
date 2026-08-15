import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/menu_model.dart';
import '../providers/admin_menu_provider.dart';
import '../widgets/promo_dashboard_view.dart';
import '../widgets/price_dashboard_view.dart';
import 'package:intl/intl.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _selectedIndex = 0;
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminMenuProvider>(context, listen: false).loadMenus();
    });
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

    if (confirm == true && mounted) {
      final success = await Provider.of<AdminMenuProvider>(context, listen: false).deleteMenu(menu.id!);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Menu berhasil dihapus')));
        } else {
          final err = Provider.of<AdminMenuProvider>(context, listen: false).errorMessage;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err ?? 'Gagal menghapus menu')));
        }
      }
    }
  }

  Future<void> _showMenuFormDialog([MenuModel? menu]) async {
    final isEdit = menu != null;
    final formKey = GlobalKey<FormState>();
    final kodeController = TextEditingController(text: menu?.kodeMenu ?? '');
    final namaController = TextEditingController(text: menu?.namaMenu ?? '');
    final kategoriController = TextEditingController(text: menu?.kategori ?? 'Makanan');
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
                    controller: kodeController,
                    decoration: const InputDecoration(labelText: 'Kode Menu (Opsional)'),
                  ),
                  TextFormField(
                    controller: namaController,
                    decoration: const InputDecoration(labelText: 'Nama Menu *'),
                    validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  TextFormField(
                    controller: kategoriController,
                    decoration: const InputDecoration(labelText: 'Kategori'),
                  ),
                  TextFormField(
                    controller: hargaController,
                    decoration: const InputDecoration(labelText: 'Harga *'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  TextFormField(
                    controller: deskripsiController,
                    decoration: const InputDecoration(labelText: 'Deskripsi'),
                    maxLines: 3,
                  ),
                  TextFormField(
                    controller: gambarController,
                    decoration: const InputDecoration(labelText: 'URL Gambar'),
                  ),
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
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final newMenu = MenuModel(
                    id: menu?.id,
                    kodeMenu: kodeController.text,
                    namaMenu: namaController.text,
                    kategori: kategoriController.text,
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
        final success = await Provider.of<AdminMenuProvider>(context, listen: false).saveMenu(result, isEdit);
        if (mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Berhasil menyimpan menu')));
          } else {
            final err = Provider.of<AdminMenuProvider>(context, listen: false).errorMessage;
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err ?? 'Gagal menyimpan menu')));
          }
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
                if (index == 3) {
                  Provider.of<AuthProvider>(context, listen: false).logout();
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
                  icon: Icon(Icons.history_outlined),
                  selectedIcon: Icon(Icons.history),
                  label: Text('Harga'),
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
            onPressed: () => Provider.of<AuthProvider>(context, listen: false).logout(),
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
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'Harga',
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
      return const PriceDashboardView();
    } else {
      return Center(
        child: Text(
          'Halaman belum diimplementasikan.',
          style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
        ),
      );
    }
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
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: provider.menus.length,
                              itemBuilder: (context, index) {
                                final menu = provider.menus[index];
                                return ListTile(
                                  leading: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      image: DecorationImage(
                                        image: NetworkImage(menu.gambar),
                                        fit: BoxFit.cover,
                                        onError: (exception, stackTrace) {},
                                      ),
                                    ),
                                    child: menu.gambar.isEmpty ? const Icon(Icons.fastfood, color: Colors.grey) : null,
                                  ),
                                  title: Text(menu.namaMenu, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text('${menu.kategori} - ${_currencyFormat.format(menu.price)}'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.blue),
                                        onPressed: () => _showMenuFormDialog(menu),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => _deleteMenu(menu),
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
      },
    );
  }
}
