import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ImpresoraService {

  Future<void> despacharComandasPorCategoria(String mesa, List<Map<String, dynamic>> itemsSeleccionados) async {
    Map<String, List<Map<String, dynamic>>> gruposPorImpresora = {};

    for (var item in itemsSeleccionados) {
      String destino = item['destino_impresora'] ?? 'Caja Generica';
      if (!gruposPorImpresora.containsKey(destino)) {
        gruposPorImpresora[destino] = [];
      }
      gruposPorImpresora[destino]!.add(item);
    }

    for (var destino in gruposPorImpresora.keys) {
      final itemsDelDestino = gruposPorImpresora[destino]!;
      String nombreCategoria = itemsDelDestino.first['categoria_nombre'];

      await _imprimirVoucherArea(mesa, nombreCategoria, destino, itemsDelDestino);
    }
  }

  Future<void> _imprimirVoucherArea(String mesa, String area, String ipDestino, List<Map<String, dynamic>> items) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Padding(
              padding: const pw.EdgeInsets.all(30),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Center(
                    child: pw.Text(
                      'ORDEN DE PREPARACIÓN: $area',
                      style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColors.red),
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text('Destino de Red: $ipDestino', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
                  pw.Divider(),
                  pw.SizedBox(height: 10),
                  pw.Text('MESA: $mesa', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  pw.Text('Hora: ${DateTime.now().toString().substring(11, 16)}', style: const pw.TextStyle(fontSize: 14)),
                  pw.SizedBox(height: 20),

                  pw.Text('ELEMENTOS A PREPARAR:', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 10),

                  ...items.map((prod) => pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 4),
                    // CORREGIDO: pw.FontWeight.normal en vez de medium
                    child: pw.Text(
                      ' [  ]  ${prod['cantidad']}x  ${prod['nombre']}',
                      style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.normal),
                    ),
                  )),

                  pw.SizedBox(height: 30),
                  pw.Divider(),
                ],
              ),
            );
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'Comanda_${area}_$mesa',
      );
    } catch (e) {
      debugPrint("Error imprimiendo sub-comanda en $ipDestino: $e");
    }
  }
}