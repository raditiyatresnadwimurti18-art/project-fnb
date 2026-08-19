import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/report_provider.dart';
import '../core/theme/app_theme.dart';

class ReportDashboardView extends StatefulWidget {
  const ReportDashboardView({super.key});

  @override
  State<ReportDashboardView> createState() => _ReportDashboardViewState();
}

class _ReportDashboardViewState extends State<ReportDashboardView> {
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReportProvider>(context, listen: false).loadReport();
    });
  }

  Future<void> _selectDateRange() async {
    final provider = Provider.of<ReportProvider>(context, listen: false);
    final initialDateRange = DateTimeRange(
      start: provider.startDate ?? DateTime.now().subtract(const Duration(days: 7)),
      end: provider.endDate ?? DateTime.now(),
    );

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: initialDateRange,
    );

    if (picked != null) {
      provider.setDateRange(picked.start, picked.end);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReportProvider>(
      builder: (context, provider, child) {
        return Container(
          color: Colors.grey.shade50,
          padding: EdgeInsets.all(MediaQuery.of(context).size.width > 600 ? 24.0 : 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 16,
                runSpacing: 16,
                children: [
                  const Text(
                    'Laporan Penjualan',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'today') {
                        provider.setDateRange(null, null);
                      } else if (value == 'all_time') {
                        provider.setDateRange(DateTime(2020), DateTime.now());
                      } else if (value == 'custom') {
                        _selectDateRange();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'today', child: Text('Hari Ini')),
                      const PopupMenuItem(value: 'all_time', child: Text('Semua Waktu')),
                      const PopupMenuItem(value: 'custom', child: Text('Pilih Rentang Tanggal...')),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: AppTheme.primaryColor),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_today, color: AppTheme.primaryColor, size: 18),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              provider.startDate == null
                                  ? 'Hari Ini'
                                  : (provider.startDate!.year == 2020
                                      ? 'Semua Waktu'
                                      : '${DateFormat('dd MMM yy').format(provider.startDate!)} - ${DateFormat('dd MMM yy').format(provider.endDate!)}'),
                              style: const TextStyle(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_drop_down, color: AppTheme.primaryColor),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (provider.isLoading)
                const Expanded(child: Center(child: CircularProgressIndicator()))
              else if (provider.errorMessage != null)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 48),
                        const SizedBox(height: 16),
                        Text(provider.errorMessage!, style: const TextStyle(color: Colors.red)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: provider.loadReport,
                          child: const Text('Coba Lagi'),
                        )
                      ],
                    ),
                  ),
                )
              else if (provider.reportData != null)
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Summary Cards
                        Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            _buildSummaryCard(
                              context,
                              title: 'Total Transaksi',
                              value: provider.reportData!.summary.totalTransactions.toString(),
                              icon: Icons.receipt_long,
                              color: AppTheme.primaryColor,
                            ),
                            _buildSummaryCard(
                              context,
                              title: 'Pendapatan Kotor',
                              value: _currencyFormat.format(provider.reportData!.summary.grossRevenue),
                              icon: Icons.monetization_on,
                              color: AppTheme.success,
                            ),
                            _buildSummaryCard(
                              context,
                              title: 'Total Diskon',
                              value: _currencyFormat.format(provider.reportData!.summary.totalDiscount),
                              icon: Icons.local_offer,
                              color: AppTheme.warning,
                            ),
                            _buildSummaryCard(
                              context,
                              title: 'Pendapatan Bersih',
                              value: _currencyFormat.format(provider.reportData!.summary.netRevenue),
                              icon: Icons.account_balance_wallet,
                              color: Colors.indigo,
                            ),
                            _buildSummaryCard(
                              context,
                              title: 'Total Modal',
                              value: _currencyFormat.format(provider.reportData!.summary.totalCogs),
                              icon: Icons.inventory_2,
                              color: AppTheme.error,
                            ),
                            _buildSummaryCard(
                              context,
                              title: 'Laba Kotor',
                              value: _currencyFormat.format(provider.reportData!.summary.grossProfit),
                              icon: Icons.trending_up,
                              color: Colors.teal,
                            ),
                            _buildSummaryCard(
                              context,
                              title: 'Total Nilai Persediaan',
                              value: _currencyFormat.format(provider.reportData!.summary.totalInventoryAsset),
                              icon: Icons.inventory,
                              color: Colors.deepPurple,
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          'Menu Terlaris',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: provider.reportData!.salesByMenu.isEmpty
                              ? const Padding(
                                  padding: EdgeInsets.all(24.0),
                                  child: Center(child: Text('Belum ada data penjualan menu')),
                                )
                              : ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: provider.reportData!.salesByMenu.length,
                                  separatorBuilder: (context, index) => const Divider(height: 1),
                                  itemBuilder: (context, index) {
                                    final menuData = provider.reportData!.salesByMenu[index];
                                    return ListTile(
                                      leading: const CircleAvatar(
                                        child: Icon(Icons.fastfood),
                                      ),
                                      title: Text(
                                        menuData.menuName, 
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      subtitle: Text('Terjual: ${menuData.qtySold} porsi'),
                                      trailing: Text(
                                        _currencyFormat.format(menuData.grossRevenue),
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.success),
                                      ),
                                    );
                                  },
                                ),
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          'Penggunaan Promo',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: provider.reportData!.promoAnalytics.isEmpty
                              ? const Padding(
                                  padding: EdgeInsets.all(24.0),
                                  child: Center(child: Text('Belum ada data penggunaan promo')),
                                )
                              : ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: provider.reportData!.promoAnalytics.length,
                                  separatorBuilder: (context, index) => const Divider(height: 1),
                                  itemBuilder: (context, index) {
                                    final promoData = provider.reportData!.promoAnalytics[index];
                                    return ListTile(
                                      leading: const CircleAvatar(
                                        backgroundColor: Colors.orange,
                                        child: Icon(Icons.local_offer, color: Colors.white),
                                      ),
                                      title: Text(
                                        promoData.promoName, 
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      subtitle: Text('Digunakan: ${promoData.timesUsed} kali'),
                                      trailing: Text(
                                        '-${_currencyFormat.format(promoData.totalDiscountGiven)}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.error),
                                      ),
                                    );
                                  },
                                ),
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          'Penjualan per Kasir',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: provider.reportData!.salesByKasir.isEmpty
                              ? const Padding(
                                  padding: EdgeInsets.all(24.0),
                                  child: Center(child: Text('Belum ada data penjualan per kasir')),
                                )
                              : ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: provider.reportData!.salesByKasir.length,
                                  separatorBuilder: (context, index) => const Divider(height: 1),
                                  itemBuilder: (context, index) {
                                    final kasirData = provider.reportData!.salesByKasir[index];
                                    String displayName = kasirData.user?.name ?? 'Unknown';
                                    if (kasirData.user?.username != null && kasirData.user!.username.isNotEmpty) {
                                      displayName += ' (@${kasirData.user!.username})';
                                    }
                                    return ListTile(
                                      leading: const CircleAvatar(
                                        child: Icon(Icons.person),
                                      ),
                                      title: Text(
                                        displayName, 
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      subtitle: Text('${kasirData.totalTransactions} Transaksi'),
                                      trailing: Text(
                                        _currencyFormat.format(kasirData.totalRevenue),
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.success),
                                      ),
                                    );
                                  },
                                ),
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          'Daftar Transaksi',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: provider.reportData!.invoices.isEmpty
                              ? const Padding(
                                  padding: EdgeInsets.all(24.0),
                                  child: Center(child: Text('Belum ada data transaksi')),
                                )
                              : ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: provider.reportData!.invoices.length,
                                  separatorBuilder: (context, index) => const Divider(height: 1),
                                  itemBuilder: (context, index) {
                                    final invoiceData = provider.reportData!.invoices[index];
                                    final dateStr = invoiceData.createdAt.isNotEmpty
                                        ? DateFormat('dd MMM yyyy HH:mm').format(DateTime.parse(invoiceData.createdAt))
                                        : '-';
                                    return ListTile(
                                      leading: const CircleAvatar(
                                        backgroundColor: AppTheme.primaryLight,
                                        child: Icon(Icons.receipt_long, color: AppTheme.primaryColor),
                                      ),
                                      title: Text(
                                        invoiceData.invoiceNumber,
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Text('$dateStr • Kasir: ${invoiceData.kasirName}'),
                                      trailing: Text(
                                        _currencyFormat.format(invoiceData.totalAmount),
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryColor),
                                      ),
                                      onTap: () => _showInvoiceDialog(context, invoiceData.invoiceNumber),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                )
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(BuildContext context, {required String title, required String value, required IconData icon, required Color color}) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
    );
  }
  void _showInvoiceDialog(BuildContext context, String invoiceNumber) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusLarge)),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          child: FutureBuilder<Map<String, dynamic>>(
            future: Provider.of<ReportProvider>(context, listen: false).getInvoiceData(invoiceNumber),
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
}
