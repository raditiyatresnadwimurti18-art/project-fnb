import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/auth_provider.dart';
import '../providers/pos_provider.dart';
import '../models/menu_model.dart';
import '../models/promo_model.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/shimmer_loading.dart';
import '../core/widgets/custom_image_view.dart';
import '../widgets/custom_numpad.dart';

class PosDashboardPage extends StatefulWidget {
  const PosDashboardPage({super.key});

  @override
  State<PosDashboardPage> createState() => _PosDashboardPageState();
}

class _PosDashboardPageState extends State<PosDashboardPage> {
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  String _searchQuery = '';
  String _selectedCategory = 'Semua';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PosProvider>(context, listen: false).loadData();
    });
  }

  List<String> _getCategories(List<MenuModel> menus) {
    final categories = menus.map((m) => m.kategori).toSet().toList();
    categories.insert(0, 'Semua');
    return categories;
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
      final posProvider = Provider.of<PosProvider>(context, listen: false);
      posProvider.cart.clear();
      posProvider.selectPromo(null);
      posProvider.calculatedItems.clear();
      posProvider.subtotal = 0;
      posProvider.discountTotal = 0;
      posProvider.finalTotal = 0;
      
      Provider.of<AuthProvider>(context, listen: false).logout();
    }
  }

  List<MenuModel> _getFilteredMenus(List<MenuModel> menus) {
    return menus.where((menu) {
      final matchesSearch = menu.namaMenu.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'Semua' || menu.kategori == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  Future<void> _handleCheckout(PosProvider provider) async {
    bool isProcessing = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (stateContext, setStateDialog) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: CustomNumpad(
                totalTagihan: provider.finalTotal,
                isProcessing: isProcessing,
                onCancel: () => Navigator.pop(dialogContext),
                onSubmit: (payment) async {
                  setStateDialog(() => isProcessing = true);
                  final success = await provider.checkout(payment);
                  
                  if (!dialogContext.mounted) return;
                  Navigator.pop(dialogContext); // Tutup dialog numpad
                  
                  if (!mounted) return;
                  if (success) {
                    _showSuccessDialog(provider.lastInvoiceNumber ?? '-', provider.lastChangeAmount);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(provider.errorMessage ?? 'Gagal checkout transaksi!'),
                        backgroundColor: AppTheme.error,
                      ),
                    );
                  }
                },
              ),
            );
          },
        );
      },
    );
  }

  void _showSuccessDialog(String invoice, double change) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusLarge)),
        child: Container(
          width: 350,
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppTheme.successLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, color: AppTheme.success, size: 48),
              ),
              const SizedBox(height: 24),
              const Text('Transaksi Berhasil!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Invoice: $invoice', style: const TextStyle(color: AppTheme.textSecondary)),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Divider(), 
              ),
              const Text('Kembalian', style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
              const SizedBox(height: 8),
              Text(
                _currencyFormat.format(change),
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppTheme.primaryColor),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context); // Tutup dialog sukses
                    _showInvoiceDialog(invoice);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppTheme.primaryColor),
                  ),
                  child: const Text('Lihat Detail Transaksi', style: TextStyle(fontSize: 16, color: AppTheme.primaryColor)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Transaksi Baru', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showInvoiceDialog(String invoiceNumber) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusLarge)),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          child: FutureBuilder<Map<String, dynamic>>(
            future: Provider.of<PosProvider>(context, listen: false).getInvoiceData(invoiceNumber),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 300,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return SizedBox(
                  height: 300,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: AppTheme.error, size: 48),
                      const SizedBox(height: 16),
                      Text('Gagal memuat invoice', style: TextStyle(color: AppTheme.error)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Tutup'),
                      ),
                    ],
                  ),
                );
              }
              
              final data = snapshot.data!;
              final items = data['items'] as List<dynamic>? ?? [];
              final subtotal = double.tryParse(data['subtotal']?.toString() ?? '0') ?? 0;
              final discount = double.tryParse(data['discount_amount']?.toString() ?? '0') ?? 0;
              final total = double.tryParse(data['total_amount']?.toString() ?? '0') ?? 0;
              final payment = double.tryParse(data['payment_amount']?.toString() ?? '0') ?? 0;
              final change = double.tryParse(data['change_amount']?.toString() ?? '0') ?? 0;

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Detail Transaksi', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text('Invoice: ${data['invoice_number']}', style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text('Kasir: ${data['user']?['name'] ?? '-'}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                  Text('Tanggal: ${data['created_at'] != null ? DateFormat('dd MMM yyyy HH:mm').format(DateTime.parse(data['created_at'])) : '-'}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                  const SizedBox(height: 16),
                  
                  // Items
                  const Text('Daftar Pesanan:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Flexible(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 250),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: items.length,
                        separatorBuilder: (ctx, i) => const Divider(height: 16),
                        itemBuilder: (ctx, index) {
                          final item = items[index];
                          final qty = item['qty'] ?? 1;
                          final price = double.tryParse(item['price']?.toString() ?? '0') ?? 0;
                          final menuName = item['menu']?['nama_menu'] ?? 'Item $index';
                          final isFree = price == 0;
                          
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${qty}x', style: const TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(menuName, style: const TextStyle(fontWeight: FontWeight.w600)),
                                    if (isFree)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                        decoration: BoxDecoration(color: AppTheme.successLight, borderRadius: BorderRadius.circular(4)),
                                        child: const Text('GRATIS', style: TextStyle(color: AppTheme.success, fontSize: 10, fontWeight: FontWeight.bold)),
                                      ),
                                  ],
                                ),
                              ),
                              Text(isFree ? 'Rp 0' : _currencyFormat.format(price * qty)),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(thickness: 2),
                  ),
                  
                  // Summary
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Subtotal'),
                      Text(_currencyFormat.format(subtotal)),
                    ],
                  ),
                  if (discount > 0) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Diskon Promo', style: TextStyle(color: AppTheme.success)),
                        Text('-${_currencyFormat.format(discount)}', style: const TextStyle(color: AppTheme.success)),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Bayar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(_currencyFormat.format(total), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.background,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Tunai', style: TextStyle(color: AppTheme.textSecondary)),
                            Text(_currencyFormat.format(payment)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Kembalian', style: TextStyle(color: AppTheme.textSecondary)),
                            Text(_currencyFormat.format(change), style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      body: Consumer<PosProvider>(
        builder: (context, provider, child) {
          provider.currentUserId = authProvider.userId ?? 1;
          
          return LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth > 900;
              
              return Row(
                children: [
                  // Left Side: Main Content (Menu Grid)
                  Expanded(
                    flex: isDesktop ? 7 : 1,
                    child: Column(
                      children: [
                        _buildHeader(provider, isDesktop),
                        _buildFilterBar(provider),
                        Expanded(child: _buildMenuGrid(provider, isDesktop)),
                      ],
                    ),
                  ),
                  
                  // Right Side: Cart Sidebar (Desktop only)
                  if (isDesktop) ...[
                    const VerticalDivider(width: 1),
                    SizedBox(
                      width: 400, // Fixed width for sidebar looks better than flex
                      child: _buildCartPanel(provider, isMobile: false),
                    ),
                  ],
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth > 900;
          if (isDesktop) return const SizedBox.shrink();
          
          return Consumer<PosProvider>(
            builder: (context, provider, child) {
              if (provider.cart.isEmpty) return const SizedBox.shrink();
              return FloatingActionButton.extended(
                backgroundColor: AppTheme.primaryColor,
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) {
                      return DraggableScrollableSheet(
                        initialChildSize: 0.9,
                        maxChildSize: 0.95,
                        minChildSize: 0.5,
                        builder: (_, controller) {
                          return Container(
                            decoration: const BoxDecoration(
                              color: AppTheme.background,
                              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                            ),
                            child: _buildCartPanel(provider, isMobile: true),
                          );
                        },
                      );
                    },
                  );
                },
                icon: const Icon(Icons.shopping_cart, color: Colors.white),
                label: Text(
                  '${provider.cart.length} Item • ${_currencyFormat.format(provider.finalTotal)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
              );
            },
          );
        }
      ),
    );
  }

  Widget _buildHeader(PosProvider provider, bool isDesktop) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: AppTheme.surface,
      child: Row(
        children: [
          if (!isDesktop) ...[
            const Icon(Icons.point_of_sale, color: AppTheme.primaryColor),
            const SizedBox(width: 12),
          ],
          const Text(
            'Kasir',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            ),
            child: Row(
              children: [
                const Icon(Icons.person, size: 16, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  (Provider.of<AuthProvider>(context, listen: false).role ?? '').toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.logout, color: AppTheme.textSecondary),
            tooltip: 'Logout',
            onPressed: _confirmLogout,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(PosProvider provider) {
    final categories = _getCategories(provider.menus);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: AppTheme.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              hintText: 'Cari menu...',
              prefixIcon: const Icon(Icons.search, color: AppTheme.textHint),
              filled: true,
              fillColor: AppTheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
          const SizedBox(height: 16),
          // Category Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedCategory = cat);
                    },
                    backgroundColor: AppTheme.surface,
                    selectedColor: AppTheme.primaryColor,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.textPrimary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    side: BorderSide(color: isSelected ? AppTheme.primaryColor : AppTheme.border),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuGrid(PosProvider provider, bool isDesktop) {
    if (provider.isLoading) {
      return GridView.builder(
        padding: const EdgeInsets.all(24),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 220,
          childAspectRatio: 0.72,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: 8, // dummy count for shimmer
        itemBuilder: (context, index) => _buildMenuShimmer(),
      );
    }

    final filteredMenus = _getFilteredMenus(provider.menus);

    if (filteredMenus.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: AppTheme.border),
            SizedBox(height: 16),
            Text('Menu tidak ditemukan', style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220, // Responsive columns instead of fixed count
        childAspectRatio: 0.72,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: filteredMenus.length,
      itemBuilder: (context, index) {
        return _buildMenuCard(filteredMenus[index], provider);
      },
    );
  }

  Widget _buildMenuShimmer() {
    return Card(
      elevation: 0,
      color: AppTheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        side: const BorderSide(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Expanded(
            flex: 3,
            child: ShimmerLoading(width: double.infinity, height: double.infinity, borderRadius: AppTheme.radiusMedium),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  ShimmerLoading(width: double.infinity, height: 16),
                  SizedBox(height: 8),
                  ShimmerLoading(width: 80, height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(MenuModel menu, PosProvider provider) {
    final qtyInCart = provider.cart[menu.id] ?? 0;
    
    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: InkWell(
        onTap: () => provider.addToCart(menu),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(color: qtyInCart > 0 ? AppTheme.primaryColor : AppTheme.border, width: qtyInCart > 0 ? 2 : 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.radiusMedium - 2)),
                      child: CustomImageView(
                        imageString: menu.gambar,
                        fit: BoxFit.cover,
                        fallback: Container(
                          color: AppTheme.background,
                          child: const Icon(Icons.fastfood, size: 40, color: AppTheme.textHint),
                        ),
                      ),
                    ),
                    if (qtyInCart > 0)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$qtyInCart',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          menu.namaMenu,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _currencyFormat.format(menu.price),
                        style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 13,
                            color: menu.totalStock <= 5
                                ? Colors.red
                                : menu.totalStock <= 10
                                    ? Colors.orange
                                    : Colors.green,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Stok: ${menu.totalStock}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: menu.totalStock <= 5
                                  ? Colors.red
                                  : menu.totalStock <= 10
                                      ? Colors.orange
                                      : Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartPanel(PosProvider provider, {required bool isMobile}) {
    return Container(
      color: AppTheme.surface,
      child: Column(
        children: [
          // Header Sticky
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              border: const Border(bottom: BorderSide(color: AppTheme.border)),
              borderRadius: isMobile ? const BorderRadius.vertical(top: Radius.circular(24)) : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Pesanan Saat Ini',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                ),
                if (isMobile)
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_down),
                    onPressed: () => Navigator.pop(context),
                  ),
              ],
            ),
          ),
          
          // Scrollable Cart Items
          Expanded(
            child: provider.cart.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart_outlined, size: 64, color: AppTheme.border),
                        SizedBox(height: 16),
                        Text('Belum ada pesanan', style: TextStyle(color: AppTheme.textSecondary)),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: provider.calculatedItems.isNotEmpty ? provider.calculatedItems.length : provider.cart.length,
                    separatorBuilder: (context, index) => const Divider(height: 24),
                    itemBuilder: (context, index) {
                      if (provider.calculatedItems.isNotEmpty) {
                        final itemData = provider.calculatedItems[index];
                        final menuId = itemData['menu_id'] as int;
                        final qty = itemData['qty'] as int;
                        final isFree = itemData['is_free'] == true;
                        final promoName = itemData['promo_name'] as String?;
                        final menu = provider.menus.firstWhere((m) => m.id == menuId);
                        
                        return isMobile && !isFree
                          ? Dismissible(
                              key: Key('cart_item_$menuId'),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                color: AppTheme.error,
                                child: const Icon(Icons.delete, color: Colors.white),
                              ),
                              onDismissed: (_) {
                                for(int i=0; i<qty; i++){
                                  provider.removeFromCart(menu);
                                }
                              },
                              child: _buildCartItem(menu, qty, provider, isFree: isFree, promoName: promoName),
                            )
                          : _buildCartItem(menu, qty, provider, isFree: isFree, promoName: promoName);
                      } else {
                        // Fallback jika API gagal
                        final id = provider.cart.keys.elementAt(index);
                        final qty = provider.cart[id]!;
                        final menu = provider.menus.firstWhere((m) => m.id == id);
                        
                        return isMobile 
                          ? Dismissible(
                              key: Key('cart_item_$id'),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                color: AppTheme.error,
                                child: const Icon(Icons.delete, color: Colors.white),
                              ),
                              onDismissed: (_) {
                                for(int i=0; i<qty; i++){
                                  provider.removeFromCart(menu);
                                }
                              },
                              child: _buildCartItem(menu, qty, provider),
                            )
                          : _buildCartItem(menu, qty, provider);
                      }
                    },
                  ),
          ),
          
          // Footer Sticky (Checkout Section)
          _buildCheckoutSection(provider),
        ],
      ),
    );
  }

  Widget _buildCartItem(MenuModel menu, int qty, PosProvider provider, {bool isFree = false, String? promoName}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image thumbnail
        ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          child: CustomImageView(
            imageString: menu.gambar,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            fallback: Container(
              width: 60, height: 60, color: AppTheme.background,
              child: const Icon(Icons.image, color: AppTheme.textHint),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      menu.namaMenu,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isFree)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.successLight,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('GRATIS', style: TextStyle(color: AppTheme.success, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                isFree ? 'Rp 0' : _currencyFormat.format(menu.price),
                style: TextStyle(
                  color: isFree ? AppTheme.success : AppTheme.textSecondary,
                  fontSize: 13,
                  decoration: isFree ? TextDecoration.lineThrough : null,
                ),
              ),
              if (promoName != null) ...[
                const SizedBox(height: 4),
                Text(
                  promoName,
                  style: const TextStyle(color: AppTheme.primaryColor, fontSize: 11, fontStyle: FontStyle.italic),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 8),
        // Controls & Price
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              isFree ? 'Rp 0' : _currencyFormat.format(menu.price * qty),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isFree ? AppTheme.success : AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            if (!isFree)
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.border),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 18),
                      onPressed: () => provider.removeFromCart(menu),
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      padding: EdgeInsets.zero,
                    ),
                    Text('$qty', style: const TextStyle(fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.add, size: 18),
                      onPressed: () => provider.addToCart(menu),
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text('${qty}x', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildCheckoutSection(PosProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          if (provider.promos.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: DropdownButtonFormField<int?>(
                decoration: const InputDecoration(
                  labelText: 'Gunakan Promo',
                  prefixIcon: Icon(Icons.local_offer_outlined, color: AppTheme.primaryColor),
                ),
                initialValue: provider.selectedPromo?.id,
                isExpanded: true,
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('Tanpa Promo', overflow: TextOverflow.ellipsis),
                  ),
                  ...provider.promos.map((p) {
                    String benefit = p.type == 'discount'
                        ? (p.isPercentage ? '${p.value}%' : _currencyFormat.format(p.value))
                        : 'Beli ${p.buyQty ?? 1} Gratis ${p.freeQty ?? 1}';
                    
                    bool isOutOfQuota = p.quota > 0 && p.usedQuota >= p.quota;

                    return DropdownMenuItem<int?>(
                      value: p.id, 
                      enabled: !isOutOfQuota,
                      child: Text(
                        '${p.name} ($benefit)${isOutOfQuota ? ' - Habis' : ''}',
                        style: TextStyle(
                          color: isOutOfQuota ? AppTheme.textHint : AppTheme.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }),
                ],
                onChanged: (val) {
                  if (val == null) {
                    provider.selectPromo(null);
                  } else {
                    try {
                      final selected = provider.promos.firstWhere((p) => p.id == val);
                      provider.selectPromo(selected);
                    } catch (_) {
                      provider.selectPromo(null);
                    }
                  }
                },
              ),
            ),
            
          // Inline Promo Warning (Better UX than Dialog)
          if (provider.errorMessage != null)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.warningLight,
                border: Border.all(color: AppTheme.warning.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: AppTheme.warning, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      provider.errorMessage!,
                      style: const TextStyle(color: AppTheme.warning, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal', style: TextStyle(color: AppTheme.textSecondary)),
              Text(
                _currencyFormat.format(provider.subtotal),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          
          if (provider.discountTotal > 0) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Diskon Promo', style: TextStyle(color: AppTheme.success)),
                Text(
                  '-${_currencyFormat.format(provider.discountTotal)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.success),
                ),
              ],
            ),
          ],
          
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(),
          ),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Bayar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              provider.isCalculating
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(
                      _currencyFormat.format(provider.finalTotal),
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.primaryColor),
                    ),
            ],
          ),
          const SizedBox(height: 20),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: provider.cart.isEmpty || provider.isCalculating || provider.isLoading || provider.errorMessage != null
                  ? null
                  : () => _handleCheckout(provider),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: provider.isLoading && provider.cart.isNotEmpty
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Checkout', style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }
}
