
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../providers/pos_provider.dart';

class PrintingService {
  static Future<void> printReceipt(List<CartItem> cart, double total, String cafeteriaName, String receiptTitle) async {
    final doc = pw.Document();

    // High-quality Arabic font embedding for thermal printers
    final font = await PdfGoogleFonts.cairoRegular();
    final fontBold = await PdfGoogleFonts.cairoBold();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        theme: pw.ThemeData.withFont(
          base: font,
          bold: fontBold,
        ),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Directionality(
                  textDirection: pw.TextDirection.rtl,
                  child: pw.Text(cafeteriaName, 
                  style: pw.TextStyle(font: fontBold, fontSize: 18))
                ),
              ),
              pw.Center(
                child: pw.Directionality(
                  textDirection: pw.TextDirection.rtl,
                  child: pw.Text(receiptTitle, 
                  style: pw.TextStyle(font: font, fontSize: 12))
                ),
              ),
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 5),
              ...cart.map((item) {
                return pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 2),
                  child: pw.Directionality(
                    textDirection: pw.TextDirection.rtl,
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('${item.item.name} x ${item.quantity}', 
                        style: pw.TextStyle(font: font, fontSize: 10)),
                        pw.Text('${(item.item.price * item.quantity).toStringAsFixed(2)} جنيه', 
                        style: pw.TextStyle(font: font, fontSize: 10)),
                      ],
                    ),
                  ),
                );
              }).toList(),
              pw.Divider(thickness: 1),
              pw.Directionality(
                textDirection: pw.TextDirection.rtl,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('الإجمالي', 
                    style: pw.TextStyle(font: fontBold, fontSize: 14)),
                    pw.Text('${total.toStringAsFixed(2)} جنيه', 
                    style: pw.TextStyle(font: fontBold, fontSize: 14)),
                  ],
                ),
              ),
              pw.SizedBox(height: 15),
              pw.Center(
                child: pw.Directionality(
                  textDirection: pw.TextDirection.rtl,
                  child: pw.Text('شكراً لزيارتكم!', 
                  style: pw.TextStyle(font: font, fontSize: 10))
                ),
              ),
              pw.Center(
                child: pw.Text(DateTime.now().toString().split('.')[0], 
                style: pw.TextStyle(font: font, fontSize: 8))
              ),
            ],
          );
        },
      ),
    );

    // This command opens the printer dialog and ensures font embedding
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: 'Receipt',
    );
  }
}
