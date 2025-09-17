import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../shopping_list/model/store_purchase_models.dart';

class ReceiptPdfService {
  static Future<String> generateReceiptPdf({
    required Purchase purchase,
    required List<PurchaseItem> items,
  }) async {
    final pdf = pw.Document();
    
    // Calcular totales
    final totalItems = items.fold(0, (sum, item) => sum + item.qty);
    final grandTotal = items.fold(0.0, (sum, item) => sum + item.totalPrice);
    
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.symmetric(vertical: 15),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(width: 2),
                    borderRadius: pw.BorderRadius.circular(5),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Text(
                        'TICKET DE COMPRA',
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        'Lista Smart - Gestor de Compras',
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                
                pw.SizedBox(height: 20),
                
                // Información de la compra
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(5),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'INFORMACIÓN DE COMPRA',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      _buildInfoRow('Tienda:', purchase.storeName),
                      _buildInfoRow('Fecha:', _formatDateTime(purchase.purchaseDate)),
                      _buildInfoRow('Total de productos:', '$totalItems'),
                      if (purchase.notes != null)
                        _buildInfoRow('Notas:', purchase.notes!),
                    ],
                  ),
                ),
                
                pw.SizedBox(height: 20),
                
                // Header de la tabla
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(vertical: 8),
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(
                      bottom: pw.BorderSide(width: 1),
                    ),
                  ),
                  child: pw.Row(
                    children: [
                      pw.Expanded(flex: 3, child: pw.Text('PRODUCTO', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Expanded(flex: 1, child: pw.Text('CANT', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center)),
                      pw.Expanded(flex: 2, child: pw.Text('PRECIO', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right)),
                      pw.Expanded(flex: 2, child: pw.Text('TOTAL', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right)),
                    ],
                  ),
                ),
                
                // Lista de productos
                ...items.map((item) => pw.Container(
                  padding: const pw.EdgeInsets.symmetric(vertical: 4),
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(
                      bottom: pw.BorderSide(width: 0.5, color: PdfColors.grey300),
                    ),
                  ),
                  child: pw.Row(
                    children: [
                      pw.Expanded(
                        flex: 3,
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(item.name, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                            if (item.category != null)
                              pw.Text(item.category!, style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                            if (item.notes != null)
                              pw.Text(item.notes!, style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                          ],
                        ),
                      ),
                      pw.Expanded(
                        flex: 1,
                        child: pw.Text('${item.qty}', textAlign: pw.TextAlign.center),
                      ),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text('₡${item.unitPrice.toStringAsFixed(0)}', textAlign: pw.TextAlign.right),
                      ),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text(
                          '₡${item.totalPrice.toStringAsFixed(0)}',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                )),
                
                pw.SizedBox(height: 15),
                
                // Total
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(5),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'TOTAL A PAGAR:',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        '₡${grandTotal.toStringAsFixed(0)}',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue800,
                        ),
                      ),
                    ],
                  ),
                ),
                
                pw.Spacer(),
                
                // Footer
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.symmetric(vertical: 10),
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(
                      top: pw.BorderSide(width: 1),
                    ),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Text(
                        'Generado por Lista Smart',
                        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                      ),
                      pw.Text(
                        _formatDateTime(DateTime.now()),
                        style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
    
    // Guardar el archivo
    final output = await getTemporaryDirectory();
    final fileName = 'ticket_${purchase.storeName.replaceAll(' ', '_')}_${purchase.purchaseDate.millisecondsSinceEpoch}.pdf';
    final file = File('${output.path}/$fileName');
    await file.writeAsBytes(await pdf.save());
    
    return file.path;
  }
  
  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 80,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Expanded(child: pw.Text(value)),
        ],
      ),
    );
  }
  
  static String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} '
           '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
  
  static Future<void> shareReceiptPdf({
    required Purchase purchase,
    required List<PurchaseItem> items,
  }) async {
    try {
      final pdfPath = await generateReceiptPdf(
        purchase: purchase,
        items: items,
      );
      
      await Share.shareXFiles(
        [XFile(pdfPath)],
        text: 'Ticket de compra - ${purchase.storeName}',
        subject: 'Ticket de compra ${_formatDate(purchase.purchaseDate)}',
      );
    } catch (e) {
      throw Exception('Error al generar o compartir el PDF: $e');
    }
  }
  
  static String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}