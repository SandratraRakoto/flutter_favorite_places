import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:favorite_places/models/place.dart';
import 'package:favorite_places/providers/user_places_provider.dart';
import 'package:favorite_places/widgets/image_input.dart';
import 'package:favorite_places/widgets/location_input.dart';

class AddPlaceScreen extends ConsumerStatefulWidget {
  const AddPlaceScreen({super.key});

  @override
  ConsumerState<AddPlaceScreen> createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends ConsumerState<AddPlaceScreen> {
  final _formKey = GlobalKey<FormState>();
  String _titleField = '';
  File? _imageField;
  PlaceLocation? _pickedLocation;

  void _submitNewItem() {
    if (_formKey.currentState!.validate() &&
        _imageField != null &&
        _pickedLocation != null) {
      _formKey.currentState!.save();

      final place = Place(
          title: _titleField, image: _imageField!, location: _pickedLocation!);
      ref.read(userPlacesProvider.notifier).addPlace(place);

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add new Place'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    label: Text('Title'),
                  ),
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onBackground),
                  initialValue: _titleField,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Title is required';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _titleField = value!;
                  },
                ),
                const SizedBox(height: 16),
                ImageInput(
                  onPickedImage: (image) {
                    _imageField = image;
                  },
                ),
                const SizedBox(height: 16),
                LocationInput(
                  onSelectLocation: (location) {
                    _pickedLocation = location;
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _submitNewItem,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Place'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
