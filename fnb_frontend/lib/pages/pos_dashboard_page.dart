import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/menu_model.dart';
import '../models/promo_model.dart';
import '../providers/pos_provider.dart';
import 'package:intl/intl.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PosProvider>(context, listen: false).loadData();
    });
  }

  Future<void> _handleCheckout(PosProvider provider) async {
    final TextEditingController paymentController = TextEditingController();
    bool isProcessing = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Pembayaran'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Tagihan: ${_currencyFormat.format(provider.finalTotal)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: paymentController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Uang Pembayaran (Rp)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                if (!isProcessing)
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Batal'),
                  ),
                ElevatedButton(
                  onPressed: isProcessing
                      ? null
                      : () async {
                          final payment =
                              double.tryParse(paymentController.text) ?? 0;
                          if (payment < provider.finalTotal) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Uang pembayaran kurang!'),
                              ),
                            );
                            return;
                          }
                          setStateDialog(() => isProcessing = true);
                          final success = await provider.checkout(payment);
                          if (mounted) {
                            Navigator.pop(context); // Tutup dialog pembayaran
                            if (success) {
                              final change = provider.lastChangeAmount;
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => AlertDialog(
                                  title: const Text(
                                    'Transaksi Berhasil!',
                                    style: TextStyle(color: Colors.green),
                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Invoice: ${provider.lastInvoiceNumber}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Kembalian: ${_currencyFormat.format(change)}',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Tutup / Cetak Struk'),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(provider.errorMessage ?? 'Gagal checkout transaksi!'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                  child: isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Bayar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;
    return Consumer<PosProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          appBar: AppBar(
            title: const Text(
              'FNB Cashier POS',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.white,
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Center(
                  child: Text(
                    'Kasir: ${Provider.of<AuthProvider>(context, listen: false).role}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.red),
                tooltip: 'Logout',
                onPressed: () {
                  Provider.of<AuthProvider>(context, listen: false).logout();
                },
              ),
            ],
          ),
          floatingActionButton: isDesktop
              ? null
              : FloatingActionButton.extended(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) {
                        return DraggableScrollableSheet(
                          initialChildSize: 0.8,
                          maxChildSize: 0.9,
                          minChildSize: 0.5,
                          builder: (_, controller) {
                            return Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20),
                                ),
                              ),
                              child: _buildCartSidebar(
                                provider,
                                isMobile: true,
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.shopping_cart),
                  label: Text('${provider.cart.length} Item'),
                ),
          body: Row(
            children: [
              // Left Side: Menu Grid
              Expanded(
                flex: 7,
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Pilih Menu',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: GridView.builder(
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: isDesktop ? 3 : 2,
                                      childAspectRatio: isDesktop ? 0.85 : 0.75,
                                      crossAxisSpacing: 16,
                                      mainAxisSpacing: 16,
                                    ),
                                itemCount: provider.menus.length,
                                itemBuilder: (context, index) {
                                  final menu = provider.menus[index];
                                  return _buildMenuCard(menu, provider);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              if (isDesktop) ...[
                // Vertical Divider
                Container(width: 1, color: Colors.grey.shade200),
                // Right Side: Cart
                Expanded(
                  flex: 3,
                  child: _buildCartSidebar(provider, isMobile: false),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildCartSidebar(PosProvider provider, {required bool isMobile}) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
              borderRadius: isMobile
                  ? const BorderRadius.vertical(top: Radius.circular(20))
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.shopping_cart, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      'Pesanan Saat Ini',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (isMobile)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: provider.cart.isEmpty
                ? const Center(
                    child: Text(
                      'Belum ada pesanan',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.cart.length,
                    itemBuilder: (context, index) {
                      final id = provider.cart.keys.elementAt(index);
                      final qty = provider.cart[id]!;
                      final menu = provider.menus.firstWhere((m) => m.id == id);
                      return _buildCartItem(menu, qty, provider);
                    },
                  ),
          ),
          _buildCheckoutSection(provider),
        ],
      ),
    );
  }

  Widget _buildMenuCard(MenuModel menu, PosProvider provider) {
    return InkWell(
      onTap: () => provider.addToCart(menu),
      borderRadius: BorderRadius.circular(12),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Image.network(
                  menu.gambar,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey.shade200,
                    child: const Icon(
                      Icons.fastfood,
                      size: 40,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    menu.namaMenu,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _currencyFormat.format(menu.price),
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItem(MenuModel menu, int qty, PosProvider provider) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
            onPressed: () => provider.removeFromCart(menu),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${qty}x',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  menu.namaMenu,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  _currencyFormat.format(menu.price),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          Text(
            _currencyFormat.format(menu.price * qty),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutSection(PosProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
          // Promo Selector
          if (provider.promos.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: DropdownButtonFormField<PromoModel>(
                decoration: const InputDecoration(
                  labelText: 'Gunakan Promo',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                initialValue: provider.selectedPromo,
                isExpanded: true,
                items: [
                  const DropdownMenuItem<PromoModel>(
                    value: null,
                    child: Text('Tanpa Promo', overflow: TextOverflow.ellipsis),
                  ),
                  ...provider.promos.map(
                    (p) {
                      String benefit = p.type == 'discount'
                          ? (p.isPercentage ? '${p.value}%' : _currencyFormat.format(p.value))
                          : 'Beli ${p.buyQty ?? 1} Gratis ${p.freeQty ?? 1}';
                      
                      String minPurchaseStr = p.minPurchase > 0 
                          ? ' | Min. ${_currencyFormat.format(p.minPurchase)}' 
                          : '';

                      return DropdownMenuItem(
                        value: p, 
                        child: Text(
                          '${p.name} ($benefit$minPurchaseStr)',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }
                  ),
                ],
                onChanged: (val) {
                  provider.selectPromo(val);
                },
              ),
            ),
          if (provider.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(
                provider.errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Subtotal',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              Text(
                _currencyFormat.format(provider.subtotal),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (provider.discountTotal > 0) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Diskon Promo',
                  style: TextStyle(fontSize: 16, color: Colors.green),
                ),
                Text(
                  '-${_currencyFormat.format(provider.discountTotal)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          const Divider(height: 24, thickness: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Bayar',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              Flexible(
                child: provider.isCalculating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          _currencyFormat.format(provider.finalTotal),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed:
                  provider.cart.isEmpty ||
                      provider.isCalculating ||
                      provider.isLoading ||
                      provider.errorMessage != null
                  ? null
                  : () => _handleCheckout(provider),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
              ),
              child: provider.isLoading && provider.cart.isNotEmpty
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Checkout',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
