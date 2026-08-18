import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_theme.dart';

class CustomNumpad extends StatefulWidget {
  final double totalTagihan;
  final Function(double) onSubmit;
  final VoidCallback onCancel;
  final bool isProcessing;

  const CustomNumpad({
    super.key,
    required this.totalTagihan,
    required this.onSubmit,
    required this.onCancel,
    this.isProcessing = false,
  });

  @override
  State<CustomNumpad> createState() => _CustomNumpadState();
}

class _CustomNumpadState extends State<CustomNumpad> {
  late TextEditingController _amountController;
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  // Quick nominal chips based on typical IDR denominations
  List<double> get _quickNominals {
    List<double> nominals = [
      widget.totalTagihan, // Uang Pas
      20000,
      50000,
      100000,
      150000,
      200000,
    ];
    
    // Sort and ensure unique
    return nominals.toSet().toList()..sort();
  }

  void _onQuickNominalTap(double amount) {
    if (widget.isProcessing) return;
    setState(() {
      _amountController.text = amount.toInt().toString();
    });
  }

  double get _currentAmount {
    final text = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    return double.tryParse(text) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final double kembalian = _currentAmount - widget.totalTagihan;
    final bool isEnough = _currentAmount >= widget.totalTagihan;

    return Container(
      width: 400,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Pembayaran',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          
          // Total Tagihan & Kembalian
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Tagihan', style: TextStyle(color: AppTheme.textSecondary)),
                    Text(
                      _currencyFormat.format(widget.totalTagihan),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(kembalian < 0 ? 'Kurang' : 'Kembalian', 
                      style: TextStyle(
                        color: kembalian < 0 ? AppTheme.error : AppTheme.success,
                        fontWeight: FontWeight.w600,
                      )
                    ),
                    Text(
                      _currencyFormat.format(kembalian.abs()),
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: 18,
                        color: kembalian < 0 ? AppTheme.error : AppTheme.success,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Input Amount Field (Normal Keyboard)
          TextFormField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: AppTheme.primaryColor,
            ),
            textAlign: TextAlign.right,
            decoration: InputDecoration(
              prefixText: 'Rp ',
              prefixStyle: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: AppTheme.primaryColor,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
              ),
              filled: true,
              fillColor: AppTheme.primaryLight.withValues(alpha: 0.3),
            ),
            onChanged: (_) {
              // Trigger setState to update Kembalian calculation
              setState(() {});
            },
          ),
          const SizedBox(height: 16),

          // Quick Nominals
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: _quickNominals.map((amount) {
              return ActionChip(
                label: Text(
                  amount == widget.totalTagihan ? 'Uang Pas' : _currencyFormat.format(amount),
                  style: TextStyle(
                    color: _currentAmount == amount ? Colors.white : AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                backgroundColor: _currentAmount == amount ? AppTheme.primaryColor : AppTheme.background,
                onPressed: () => _onQuickNominalTap(amount),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.isProcessing ? null : widget.onCancel,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                  ),
                  child: const Text('Batal'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: (!isEnough || widget.isProcessing)
                      ? null
                      : () => widget.onSubmit(_currentAmount),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    backgroundColor: AppTheme.success,
                  ),
                  child: widget.isProcessing
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Bayar Sekarang', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
