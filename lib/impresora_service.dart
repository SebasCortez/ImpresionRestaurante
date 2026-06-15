import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ImpresoraService {

  Future<bool> imprimirPedidoA4(Map<String, dynamic> pedido) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Padding(
              padding: const pw.EdgeInsets.all(20),
              child: pw.Column(
                // CORREGIDO: Añadidos los dos puntos (:) y removido el fragmento roto
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Center(
                    child: pw.Text(
                      '*** REPORTE DE PEDIDO / COMANDA ***',
                      style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Divider(),
                  pw.SizedBox(height: 10),

                  pw.Text('Identificador de Mesa: ${pedido['mesa']}', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  pw.Text('Fecha y Hora: ${pedido['fecha']}', style: pw.TextStyle(fontSize: 14)),
                  pw.SizedBox(height: 20),
                  pw.Text('DETALLE DE CONSUMO:', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 10),

                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey),
                    ),
                    child: pw.Text(
                      pedido['productos'],
                      style: pw.TextStyle(fontSize: 14, lineSpacing: 5),
                    ),
                  ),
                  pw.SizedBox(height: 20),

                  pw.Align(
                    alignment: pw.Alignment.centerRight,
                    child: pw.Text(
                      'TOTAL A PAGAR: S/. ${pedido['total'].toStringAsFixed(2)}',
                      style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.SizedBox(height: 40),
                  pw.Divider(),
                  pw.Center(
                    child: pw.Text('Sistema POS Local - Impresión en formato A4', style: pw.TextStyle(color: PdfColors.grey)),
                  )
                ],
              ),
            );
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'Pedido_${pedido['mesa']}',
      );

      return true;
    } catch (e) {
      // CORREGIDO: Cambiado print por debugPrint para limpiar el warning de producción
      debugPrint("Error al generar o imprimir el PDF A4: $e");
      return false;
    }
  }
}