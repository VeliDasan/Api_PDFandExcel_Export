
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import '../models/album.dart';
import '../repository/file_repository.dart';
import '../repository/user_repository.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Album>> futureAlbum;
  late AlbumDataSource _albumDataSource;
  final AlbumRepository albumRepository = AlbumRepository();
  final FileRepository fileRepository = FileRepository();

  @override
  void initState() {
    super.initState();
    futureAlbum = albumRepository.fetchAlbum();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fetch Data Example'),
        actions: [
          FutureBuilder<List<Album>>(
            future: futureAlbum,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                return Row(
                  children: [
                    IconButton(
                        onPressed: () => fileRepository.generatePDF(snapshot.data!),
                        icon: Icon(Icons.picture_as_pdf)),
                    IconButton(
                        onPressed: () => fileRepository.generateExcel(snapshot.data!),
                        icon: Icon(Icons.file_download)),
                  ],
                );
              } else {
                return SizedBox.shrink();
              }
            },
          ),
        ],
      ),
      body: Center(
        child: FutureBuilder<List<Album>>(
          future: futureAlbum,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                _albumDataSource = AlbumDataSource(albums: snapshot.data!);
                return SfDataGrid(
                  source: _albumDataSource,
                  columns: [
                    GridColumn(columnName: 'id', label: Text('id')),
                    GridColumn(columnName: 'email', label: Text('email')),
                    GridColumn(columnName: 'firstName', label: Text('firstName')),
                    GridColumn(columnName: 'lastName', label: Text('lastName')),
                    GridColumn(columnName: 'avatar', label: Text('avatar')),
                  ],
                );
              } else if (snapshot.hasError) {
                return Text('Bir hata oluştu: ${snapshot.error}');
              }
            }
            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}

class AlbumDataSource extends DataGridSource {
  AlbumDataSource({required List<Album> albums}) {
    _albums = albums
        .map<DataGridRow>((album) => DataGridRow(cells: [
      DataGridCell<int>(columnName: 'id', value: album.id),
      DataGridCell<String>(columnName: 'email', value: album.email),
      DataGridCell<String>(columnName: 'firstName', value: album.firstName),
      DataGridCell<String>(columnName: 'lastName', value: album.lastName),
      DataGridCell<String>(columnName: 'avatar', value: album.avatar),
    ]))
        .toList();
  }

  List<DataGridRow> _albums = [];

  @override
  List<DataGridRow> get rows => _albums;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(cells: row.getCells().map<Widget>((dataGridCell) {
      return Container(
        padding: EdgeInsets.all(8.0),
        alignment: Alignment.center,
        child: Text(dataGridCell.value.toString()),
      );
    }).toList());
  }
}
