import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class UserImagePicker extends StatefulWidget {
  const UserImagePicker({super.key, required this.onPickImage});

  final void Function(File pickdImage) onPickImage;

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? _pickdImageFile;

  void _pickImage() async {
    final pickdImage = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
      maxWidth: 150,
    );
    if (pickdImage == null) {
      return;
    }

    setState(() {
      _pickdImageFile = File(pickdImage.path);
    });

    widget.onPickImage(_pickdImageFile!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey,
          foregroundImage: _pickdImageFile != null
              ? FileImage(_pickdImageFile!)
              : AssetImage('assets/images/default.png') as ImageProvider,),
      TextButton.icon(
          onPressed: _pickImage,
          icon: Icon(Icons.image),
          label: Text(
            'Add Image',
            style: TextStyle(color: Theme.of(context).primaryColor),
          ))
    ]);
  }
}
