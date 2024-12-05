import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:open_file/open_file.dart';
import '../models/album.dart';
import 'package:http/http.dart' as http;

class FileRepository {
  Future<void> generatePDF(List<Album> albums) async {
    final PdfDocument document = PdfDocument();
    final PdfGrid grid = PdfGrid();

    grid.columns.add(count: 5);
    grid.headers.add(2);

    final PdfGridRow stackHeaderRow1 = grid.headers[0];
    stackHeaderRow1.cells[0].value = 'User Info';
    stackHeaderRow1.cells[0].columnSpan = 2;
    stackHeaderRow1.cells[2].value = 'Personal Info';
    stackHeaderRow1.cells[2].columnSpan = 3;

    final PdfGridRow header = grid.headers[1];
    header.cells[0].value = 'id';
    header.cells[1].value = 'email';
    header.cells[2].value = 'firstName';
    header.cells[3].value = 'lastName';
    header.cells[4].value = 'avatar';

    grid.columns[4].width = 25;

    for (var album in albums) {
      final PdfGridRow row = grid.rows.add();
      row.cells[0].value = album.id.toString();
      row.cells[1].value = album.email;
      row.cells[2].value = album.firstName;
      row.cells[3].value = album.lastName;

      Uint8List avatarBytes;
      try {
        avatarBytes = await _downloadImage(album.avatar);
      } catch (e) {
        avatarBytes = (await rootBundle.load('assets/error_icon.png'))
            .buffer
            .asUint8List();
      }

      final PdfBitmap avatarImage = PdfBitmap(avatarBytes);
      row.cells[4].value = '';
      row.cells[4].style = PdfGridCellStyle(
        backgroundImage: avatarImage,
      );
    }

    final PdfGridRow totalRow = grid.rows.add();
    totalRow.cells[0].value = 'Total Employees : ${albums.length.toString()}';
    totalRow.cells[0].columnSpan=5;


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

  Future<Uint8List> _downloadImage(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Resim indirilemedi: $url');
    }
  }

  Future<void> generateExcel(List<Album> albums) async {
    final xlsio.Workbook workbook = xlsio.Workbook();
    final xlsio.Worksheet sheet = workbook.worksheets[0];

    sheet.getRangeByName('A1').setText('User Info');
    sheet.getRangeByName('A1').columnSpan = 2;
    sheet.getRangeByName('C1').setText('Personal Info');
    sheet.getRangeByName('C1').columnSpan = 3;

    sheet.getRangeByName('A2').setText('id');
    sheet.getRangeByName('B2').setText('email');
    sheet.getRangeByName('C2').setText('firstName');
    sheet.getRangeByName('D2').setText('lastName');
    sheet.getRangeByName('E2').setText('avatar');

    for (var i = 0; i < albums.length; i++) {
      var album = albums[i];
      var rowIndex = i + 3;
      sheet.getRangeByName('A$rowIndex').setNumber(album.id.toDouble());
      sheet.getRangeByName('B$rowIndex').setText(album.email);
      sheet.getRangeByName('C$rowIndex').setText(album.firstName);
      sheet.getRangeByName('D$rowIndex').setText(album.lastName);

      ByteData imageData;
      try {
        imageData = await NetworkAssetBundle(Uri.parse(album.avatar)).load('');
      } catch (e) {
        imageData = await rootBundle.load('assets/error_icon.png');
      }

      final List<int> imageBytes = imageData.buffer.asUint8List();
      final xlsio.Picture picture =
          sheet.pictures.addStream(rowIndex, 5, imageBytes);
      picture.width = 20;
      picture.height = 20;
    }

    final int totalRowIndex = albums.length + 3;
    sheet.getRangeByName('A$totalRowIndex').setText('Total Employees : ${albums.length.toString()}');
    sheet.getRangeByName('A1').columnSpan=1;
    sheet.getRangeByName('A9').columnSpan=5;


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
