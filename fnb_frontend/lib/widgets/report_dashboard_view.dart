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
}
