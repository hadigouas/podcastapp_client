import 'package:file_picker/file_picker.dart';

class FilePickerHelper {
  Future<FilePickerResult?> pickAudioFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null) {
        // File picked successfully
        print('Audio file picked: ${result.files.single.path}');
        return result;
      } else {
        // User canceled the picker
        print('No audio file selected');
        return null;
      }
    } catch (e) {
      print('Error picking audio file: $e');
      return null;
    }
  }

  Future<FilePickerResult?> pickPictureFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ["jpg", "png"],
        allowMultiple: false,
      );

      if (result != null) {
        // File picked successfully
        print('Picture file picked: ${result.files.single.path}');
        return result;
      } else {
        // User canceled the picker
        print('No picture file selected');
        return null;
      }
    } catch (e) {
      print('Error picking picture file: $e');
      return null;
    }
  }
}
