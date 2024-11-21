
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:open_file/open_file.dart';
import '../models/album.dart';

class FileRepository {
  Future<void> generatePDF(List<Album> albums) async {
    final PdfDocument document = PdfDocument();
    final PdfGrid grid = PdfGrid();

    grid.columns.add(count: 5);
    grid.headers.add(1);
    final PdfGridRow header = grid.headers[0];
    header.cells[0].value = 'id';
    header.cells[1].value = 'email';
    header.cells[2].value = 'firstName';
    header.cells[3].value = 'lastName';
    header.cells[4].value = 'avatar';

    for (var album in albums) {
      final PdfGridRow row = grid.rows.add();
      row.cells[0].value = album.id.toString();
      row.cells[1].value = album.email;
      row.cells[2].value = album.firstName;
      row.cells[3].value = album.lastName;
      row.cells[4].value = album.avatar;
    }

    grid.draw(page: document.pages.add());

    final List<int> bytes = document.saveSync();
    document.dispose();

    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/Output.pdf';
    final file = File(path);
    await file.writeAsBytes(bytes, flush: true);
    await OpenFile.open(path);
    print('PDF oluşturuldu ve açıldı: $path');
  }

  Future<void> generateExcel(List<Album> albums) async {
    final xlsio.Workbook workbook = xlsio.Workbook();
    final xlsio.Worksheet sheet = workbook.worksheets[0];

    sheet.getRangeByName('A1').setText('id');
    sheet.getRangeByName('B1').setText('email');
    sheet.getRangeByName('C1').setText('firstName');
    sheet.getRangeByName('D1').setText('lastName');
    sheet.getRangeByName('E1').setText('avatar');

    for (var i = 0; i < albums.length; i++) {
      var album = albums[i];
      var rowIndex = i + 2;
      sheet.getRangeByName('A$rowIndex').setNumber(album.id.toDouble());
      sheet.getRangeByName('B$rowIndex').setText(album.email);
      sheet.getRangeByName('C$rowIndex').setText(album.firstName);
      sheet.getRangeByName('D$rowIndex').setText(album.lastName);
      sheet.getRangeByName('E$rowIndex').setText(album.avatar);
    }

    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/Output.xlsx';
    final file = File(path);
    await file.writeAsBytes(bytes, flush: true);
    await OpenFile.open(path);
    print('Excel oluşturuldu ve açıldı: $path');
  }
}
