import 'package:flutter/material.dart';
import '../repositories/report_repository.dart';
import '../repositories/transaction_repository.dart';
import '../models/report_model.dart';

class ReportProvider with ChangeNotifier {
  final ReportRepository _reportRepository = ReportRepository();
  final TransactionRepository _transactionRepository = TransactionRepository();

  ReportResponseModel? reportData;
  bool isLoading = true;
  String? errorMessage;

  DateTime? startDate;
  DateTime? endDate;

  Future<void> loadReport() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      reportData = await _reportRepository.getSalesSummary(
        startDate: startDate != null ? "${startDate!.year}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}" : null,
        endDate: endDate != null ? "${endDate!.year}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')}" : null,
      );
    } catch (e) {
      errorMessage = e.toString().replaceAll('Exception: ', '');
    }

    isLoading = false;
    notifyListeners();
  }

  void setDateRange(DateTime? start, DateTime? end) {
    startDate = start;
    endDate = end;
    loadReport();
  }

  Future<Map<String, dynamic>> getInvoiceData(String invoiceNumber) async {
    // Import manually or we can instantiate here just for this call
    // Wait, let's just do it directly using http since we might not have the import.
    // Actually, I can import it at the top of the file!
    try {
      final repo = _transactionRepository;
      return await repo.getInvoice(invoiceNumber);
    } catch (e) {
      rethrow;
    }
  }
}
