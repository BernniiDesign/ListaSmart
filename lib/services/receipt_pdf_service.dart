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
    
    // Calculate totals
    final totalItems = items.fold(0, (sum, item) => sum + item.qty);
    final grandTotal = items.fold(0.0, (sum, item) => sum + item.totalPrice);
    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return pw.Container(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Professional Header with simulated gradient
                _buildHeader(),
                
                pw.SizedBox(height: 25),
                
                // Purchase information with style
                _buildPurchaseInfo(purchase, totalItems),
                
                pw.SizedBox(height: 25),
                
                // Enhanced products table
                _buildProductsTable(items),
                
                pw.SizedBox(height: 20),
                
                // Total summary with style
                _buildTotalSummary(grandTotal, totalItems),
                
                pw.Spacer(),
                
                // Elegant footer
                _buildFooter(),
              ],
            ),
          );
        },
      ),
    );
    
    // Save file
    final output = await getTemporaryDirectory();
    final fileName = 'ticket_${purchase.storeName.replaceAll(' ', '_')}_${purchase.purchaseDate.millisecondsSinceEpoch}.pdf';
    final file = File('${output.path}/$fileName');
    await file.writeAsBytes(await pdf.save());
    
    return file.path;
  }

  static pw.Widget _buildHeader() {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(25),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue800,
        borderRadius: pw.BorderRadius.circular(15),
      ),
      child: pw.Column(
        children: [
          // Main simulated icon
          pw.Container(
            width: 60,
            height: 60,
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: pw.BorderRadius.circular(30),
            ),
            child: pw.Center(
              child: pw.Container(
                width: 40,
                height: 40,
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue600,
                  borderRadius: pw.BorderRadius.circular(20),
                ),
                child: pw.Center(
                  child: pw.Text(
                    '\$',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          pw.SizedBox(height: 15),
          pw.Text(
            'TICKET DE COMPRA',
            style: pw.TextStyle(
              fontSize: 28,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Lista Smart - Gestor Inteligente de Compras',
            style: pw.TextStyle(
              fontSize: 14,
              color: PdfColors.blue100,
              fontStyle: pw.FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildPurchaseInfo(Purchase purchase, int totalItems) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(color: PdfColors.grey300, width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Container(
                width: 8,
                height: 8,
                decoration: pw.BoxDecoration(
                  color: PdfColors.green600,
                  borderRadius: pw.BorderRadius.circular(4),
                ),
              ),
              pw.SizedBox(width: 10),
              pw.Text(
                'DETALLES DE COMPRA',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey800,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 15),
          _buildStylishInfoRow('STORE', 'Tienda:', purchase.storeName),
          _buildStylishInfoRow('DATE', 'Fecha:', _formatDateTime(purchase.purchaseDate)),
          _buildStylishInfoRow('ITEMS', 'Total productos:', '$totalItems articulos'),
          if (purchase.notes != null)
            _buildStylishInfoRow('NOTES', 'Notas:', purchase.notes!),
        ],
      ),
    );
  }

  static pw.Widget _buildStylishInfoRow(String iconText, String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 25,
            height: 16,
            decoration: pw.BoxDecoration(
              color: PdfColors.blue200,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Center(
              child: pw.Text(
                iconText.substring(0, 1),
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue800,
                ),
              ),
            ),
          ),
          pw.SizedBox(width: 10),
          pw.SizedBox(
            width: 100,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey700,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(
                color: PdfColors.grey800,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildProductsTable(List<PurchaseItem> items) {
    return pw.Column(
      children: [
        // Enhanced table header
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.symmetric(vertical: 12, horizontal: 15),
          decoration: pw.BoxDecoration(
            color: PdfColors.indigo800,
            borderRadius: const pw.BorderRadius.only(
              topLeft: pw.Radius.circular(10),
              topRight: pw.Radius.circular(10),
            ),
          ),
          child: pw.Row(
            children: [
              pw.Expanded(
                flex: 4,
                child: pw.Text(
                  'PRODUCTO',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                    fontSize: 12,
                  ),
                ),
              ),
              pw.Expanded(
                flex: 1,
                child: pw.Text(
                  'CANT',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                    fontSize: 12,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ),
              pw.Expanded(
                flex: 2,
                child: pw.Text(
                  'PRECIO',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                    fontSize: 12,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ),
              pw.Expanded(
                flex: 2,
                child: pw.Text(
                  'SUBTOTAL',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                    fontSize: 12,
                  ),
                  textAlign: pw.TextAlign.right,
                ),
              ),
            ],
          ),
        ),
        
        // Products
        pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300, width: 1),
            borderRadius: const pw.BorderRadius.only(
              bottomLeft: pw.Radius.circular(10),
              bottomRight: pw.Radius.circular(10),
            ),
          ),
          child: pw.Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isEven = index % 2 == 0;
              
              return pw.Container(
                padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                decoration: pw.BoxDecoration(
                  color: isEven ? PdfColors.grey50 : PdfColors.white,
                ),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      flex: 4,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            item.name,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 11,
                              color: PdfColors.grey800,
                            ),
                          ),
                          if (item.category != null) ...[
                            pw.SizedBox(height: 2),
                            pw.Container(
                              padding: const pw.EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: pw.BoxDecoration(
                                color: PdfColors.blue100,
                                borderRadius: pw.BorderRadius.circular(8),
                              ),
                              child: pw.Text(
                                item.category!,
                                style: pw.TextStyle(
                                  fontSize: 8,
                                  color: PdfColors.blue800,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                          if (item.notes != null) ...[
                            pw.SizedBox(height: 2),
                            pw.Text(
                              item.notes!,
                              style: pw.TextStyle(
                                fontSize: 8,
                                color: PdfColors.grey600,
                                fontStyle: pw.FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    pw.Expanded(
                      flex: 1,
                      child: pw.Container(
                        alignment: pw.Alignment.center,
                        child: pw.Container(
                          padding: const pw.EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: pw.BoxDecoration(
                            color: PdfColors.orange100,
                            borderRadius: pw.BorderRadius.circular(12),
                          ),
                          child: pw.Text(
                            '${item.qty}',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.orange800,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text(
                        _formatCurrency(item.unitPrice),
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text(
                        _formatCurrency(item.totalPrice),
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 11,
                          color: PdfColors.green700,
                        ),
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildTotalSummary(double grandTotal, int totalItems) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.green600,
        borderRadius: pw.BorderRadius.circular(15),
      ),
      child: pw.Column(
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'TOTAL A PAGAR',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    '$totalItems articulos',
                    style: pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.green100,
                    ),
                  ),
                ],
              ),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 8,
                ),
                decoration: pw.BoxDecoration(
                  color: PdfColors.white,
                  borderRadius: pw.BorderRadius.circular(25),
                ),
                child: pw.Text(
                  _formatCurrency(grandTotal),
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.green800,
                  ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Container(
            width: double.infinity,
            height: 2,
            decoration: pw.BoxDecoration(
              color: PdfColors.green400,
              borderRadius: pw.BorderRadius.circular(1),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(vertical: 15),
      decoration: pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(width: 2, color: PdfColors.grey300),
        ),
      ),
      child: pw.Column(
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Container(
                width: 20,
                height: 20,
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue600,
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Center(
                  child: pw.Text(
                    'OK',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 8,
                    ),
                  ),
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Text(
                'Generado por Lista Smart',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey700,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            'Fecha de generacion: ${_formatDateTime(DateTime.now())}',
            style: pw.TextStyle(
              fontSize: 9,
              color: PdfColors.grey500,
              fontStyle: pw.FontStyle.italic,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Gracias por usar nuestra aplicacion!',
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColors.blue600,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Enhanced currency formatting function without problematic symbol
  static String _formatCurrency(double amount) {
    final formatted = amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    return 'CRC $formatted'; // Use CRC instead of ₡ symbol
  }
  
  static String _formatDateTime(DateTime dateTime) {
    final months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    
    return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year} '
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