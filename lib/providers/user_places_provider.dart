import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart' as syspaths;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';

import 'package:favorite_places/models/place.dart';

Future<Database> _getDatabase() async {
  final dbPath = await sql.getDatabasesPath();
  return sql.openDatabase(
    path.join(dbPath, 'places.db'),
    onCreate: (db, version) {
      db.execute(
          'CREATE TABLE user_places(id TEXT PRIMARY KEY, title TEXT, imagePath TEXT, latitude REAL, longitude REAL, address TEXT)');
    },
    version: 1,
  );
}

class UserPlacesProviderNotifier extends StateNotifier<List<Place>> {
  UserPlacesProviderNotifier() : super([]);

  void setPlaces(List<Place> places) {
    state = places;
  }

  Future<void> loadPlaces() async {
    final db = await _getDatabase();
    final data = await db.query('user_places');
    state = data
        .map(
          (row) => Place(
            id: row['id'] as String,
            title: row['title'] as String,
            image: File(row['imagePath'] as String),
            location: PlaceLocation(
                address: row['address'] as String,
                latitude: row['latitude'] as double,
                longitude: row['longitude'] as double),
          ),
        )
        .toList();
  }

  void addPlace(Place place) async {
    final appDir = await syspaths.getApplicationDocumentsDirectory();
    final filename = path.basename(place.image.path);

    final copiedImage = await place.image.copy('${appDir.path}/$filename');
    place.image = copiedImage;

    final db = await _getDatabase();
    db.insert('user_places', {
      'id': place.id,
      'title': place.title,
      'imagePath': place.image.path,
      'longitude': place.location.longitude,
      'latitude': place.location.latitude,
      'address': place.location.address,
    });

    state = [...state, place];
  }

  void removePlace(Place place) {
    final newPlaces = List.of(state);
    newPlaces.removeWhere((p) => p.id == place.id);

    state = newPlaces;
  }

  void updatePlace(Place place) {
    final newPlaces = List.of(state);
    final placeIndex = newPlaces.indexWhere((p) => p.id == place.id);
    newPlaces.removeAt(placeIndex);
    newPlaces.insert(placeIndex, place);

    state = newPlaces;
  }
}

final userPlacesProvider =
    StateNotifierProvider<UserPlacesProviderNotifier, List<Place>>(
        (ref) => UserPlacesProviderNotifier());
