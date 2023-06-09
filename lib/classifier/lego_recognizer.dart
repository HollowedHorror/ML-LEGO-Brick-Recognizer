// Copyright (c) 2022 Kodeco LLC

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.

// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
// distribute, sublicense, create a derivative work, and/or sell copies of the
// Software in any work that is designed, intended, or marketed for pedagogical
// or instructional purposes related to programming, coding,
// application development, or information technology.  Permission for such use,
// copying, modification, merger, publication, distribution, sublicensing,
// creation of derivative works, or sale is expressly withheld.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'classifier.dart';
import '../styles.dart';
import 'lego_photo_view.dart';

import '../history_page.dart';

import 'package:firebase_ml_model_downloader/firebase_ml_model_downloader.dart';

class LegoRecogniser extends StatefulWidget {
  const LegoRecogniser({super.key});

  @override
  State<LegoRecogniser> createState() => _LegoRecogniserState();
}

//enumerator function for setting the status of a scan result
//this is used when the result is or is not found, changing the print output
enum _ResultStatus {
  notStarted,
  notFound,
  found,
}

//This entire class is what is used to set up the LEGO scanning feature
//it contains the UI for the page, how the user selects the scan method,
//how the user's LEGO image is displayed and processed with the model.
class _LegoRecogniserState extends State<LegoRecogniser> {
  //used to check if the image is in the process of being analyized by the model
  bool _isAnalyzing = false;
  //initialize picker to use the image picker package for selecting images from the user's camera roll
  final picker = ImagePicker();
  //used for accessing the selected image from the image gallery
  File? _selectedImageFile;

  // Result for Brick Classifier
  //initialize result status to notStarted yet
  _ResultStatus _legoResultStatus = _ResultStatus.notStarted;
  //the string for printing the Model Label (the name of the LEGO brick)
  String _legoLabel = '';
  //initialize the accuracy variable to zero
  double _legoAccuracy = 0.0;

  // Result for Color Classifier
  //initialize result status to notStarted yet
  _ResultStatus _colorResultStatus = _ResultStatus.notStarted;
  //the string for printing the Model Label (the color of the LEGO brick)
  String _colorLabel = '';
  //initialize the accuracy variable to zero
  double _colorAccuracy = 0.0;

  //initialize a classifier type, using the class from the classifier.dart file.
  late Classifier _classifier;
  late Classifier _colorClassifier;

  //this initializes the 'state' of the application and calls the _loadClassifier funciton below
  @override
  void initState() {
    super.initState();
    _loadClassifier();
  }

  Future<void> _loadClassifier() async {
    //local file paths
    const labelsFileName = 'assets/brick_labels.txt';
    const modelFileName = 'brick_model_unquant.tflite';

    const colorLabelFileName = 'assets/color_labels.txt';
    const colorModelFileName = 'color_unquant.tflite';

    // firebase model names
    String firebaseLegoModelName = 'brick_model_unquant';
    String firebaseColorModelName = 'color_unquant';

    //get models from firebase
    FirebaseCustomModel? firebaseLegoModel;
    FirebaseCustomModel? firebaseColorModel;

    // Initialize with local models first
    firebaseLegoModel = await FirebaseModelDownloader.instance.getModel(
        firebaseLegoModelName,
        FirebaseModelDownloadType.localModelUpdateInBackground);

    firebaseColorModel = await FirebaseModelDownloader.instance.getModel(
        firebaseColorModelName,
        FirebaseModelDownloadType.localModelUpdateInBackground);

    //NEW CODE HERE
    String legoModelPath = firebaseLegoModel != null &&
            firebaseLegoModel.file != null &&
            await File(firebaseLegoModel.file.path).exists()
        ? firebaseLegoModel.file.path
        : modelFileName;
    String colorModelPath = firebaseColorModel != null &&
            firebaseColorModel.file != null &&
            await File(firebaseColorModel.file.path).exists()
        ? firebaseColorModel.file.path
        : colorModelFileName;

    //print to the debug console the model being used and its labels
    debugPrint(
      'Start loading of Classifier with '
      'labels at $labelsFileName, '
      'model at $modelFileName',
    );

    //initialize classifier, by waiting for the Classifier class's loadWith() function
    //loads the classifier using the input model and labels and assigns them to mutable
    //variables.
    final legoClassifier = await Classifier.loadWith(
      labelsFileName: labelsFileName,
      //modelFileName: legoModelPath,
      modelFileName: modelFileName,
    );
    final colorClassifier = await Classifier.loadWith(
      labelsFileName: colorLabelFileName,
      //modelFileName: colorModelPath,
      modelFileName: colorModelFileName,
    );

    //this generated classifier is then assigned to the earlier initialized classifier
    //the ! means that the 'classifier' is checked to not be null first.
    _classifier = legoClassifier!;
    _colorClassifier = colorClassifier!;
  }

  //This is a build widget, which dynamically builds the structure of the UI of this page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("BrixColor Finder"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildPhotolView(),
            const SizedBox(height: 5),
            _buildResultView(),
            const SizedBox(height: 5),
            Column(
              children: [
                _buildPickPhotoButton(
                  title: 'Take a picture of a LEGO\u00AE',
                  source: ImageSource.camera,
                ),
                _buildPickPhotoButton(
                  title: 'Pick a LEGO\u00AE from gallery',
                  source: ImageSource.gallery,
                ),
                ElevatedButton(
                  child: Container(
                      width: 300,
                      height: 40,
                      child: const Center(
                          child: Text(
                        'Tips for taking photos',
                        style: TextStyle(
                          fontFamily: kButtonFont,
                          fontSize: 20.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ))),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) =>
                          _buildTipDialog(context),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // widget for creating the popup dialog for the tip button
  Widget _buildTipDialog(BuildContext context) {
    return AlertDialog(
      title: const Text(
          'Some tips for taking LEGO\u00AE brick photos effectively:'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const <Widget>[
          Text(
              "-Take your pictures at 3 times magnification so you may take your photos close without blurring the image.\n\n-Take pictures in a well lit area with neutral colored lighting.\n\n-Don't take pictures directly from above, as some bricks will look identical.\n\n-Use white or dark brown backgrounds if possible.\n\n-Make sure the LEGO\u00AE brick is as center frame as possible."),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
      ],
    );
  }

  // widget that creates the view of the taken image on the page
  Widget _buildPhotolView() {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        LegoPhotoView(file: _selectedImageFile),
        _buildAnalyzingText(),
      ],
    );
  }

  Widget _buildAnalyzingText() {
    if (!_isAnalyzing) {
      return const SizedBox.shrink();
    }
    return const Text('Scanning for LEGOs...', style: kAnalyzingTextStyle);
  }

  Widget _buildPickPhotoButton({
    required ImageSource source,
    required String title,
  }) {
    return ElevatedButton(
      onPressed: () => _onPickPhoto(source),
      child: Container(
        width: 300,
        height: 40,
        child: Center(
            child: Text(title,
                style: const TextStyle(
                  fontFamily: kButtonFont,
                  fontSize: 20.0,
                  fontWeight: FontWeight.w600,
                ))),
      ),
    );
  }

  void _setAnalyzing(bool flag) {
    setState(() {
      _isAnalyzing = flag;
    });
  }

  void _onPickPhoto(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile == null) {
      return;
    }

    final imageFile = File(pickedFile.path);
    setState(() {
      _selectedImageFile = imageFile;
    });

    _analyzeImage(imageFile);
  }

  void _analyzeImage(File image) {
    _setAnalyzing(true);

    final imageInput = img.decodeImage(image.readAsBytesSync())!;

    final legoResultCategory = _classifier.predict(imageInput);

    final legoResult = legoResultCategory.score >= 0.8
        ? _ResultStatus.found
        : _ResultStatus.notFound;
    final legoLabel = legoResultCategory.label;
    final legoAccuracy = legoResultCategory.score;

    final colorResultCategory = _colorClassifier.predict(imageInput);

    final colorResult = colorResultCategory.score >= 0.8
        ? _ResultStatus.found
        : _ResultStatus.notFound;
    final colorLabel = colorResultCategory.label;
    final colorAccuracy = colorResultCategory.score;

    _setAnalyzing(false);

    setState(() {
      _legoResultStatus = legoResult;
      _legoLabel = legoLabel;
      _legoAccuracy = legoAccuracy;
      _colorResultStatus = colorResult;
      _colorLabel = colorLabel;
      _colorAccuracy = colorAccuracy;

      // Update the history with the results of the scan
      var historyModel = context.read<HistoryModel>();
      historyModel.addNewScan(legoLabel, colorLabel, image);
    });
  }

  Widget _buildResultView() {
    var title = ''; //initialize title to be blanck
    var color = '';

    //This ifelse block is used for displaying the result text
    if (_legoResultStatus == _ResultStatus.notFound) {
      title = 'LEGO not detected';
    } else if (_legoResultStatus == _ResultStatus.found) {
      title = _legoLabel; //this prints the resulting label
    } else {
      title = '';
    }

    //This ifelse block is used for displaying the result text
    if (_colorResultStatus == _ResultStatus.notFound) {
      color = 'Color uncertain';
    } else if (_colorResultStatus == _ResultStatus.found) {
      if (_colorResultStatus == _ResultStatus.found) {
        color = _colorLabel;
      }
    } else {
      color = '';
    }

    //This is were the accuracy result text is created
    var accuracyLabel = '';
    var colorAccuracyLabel = '';
    if (_legoResultStatus == _ResultStatus.found) {
      accuracyLabel =
          'Brick confidence: ${(_legoAccuracy * 100).toStringAsFixed(2)}%';
    }
    if (_colorResultStatus == _ResultStatus.found) {
      colorAccuracyLabel =
          'Color confidence: ${(_colorAccuracy * 100).toStringAsFixed(2)}%';
    }

    //This is the widget were the LEGO label and accuracy result is located
    return Column(
      children: [
        Text(title, style: kResultTextStyle),
        const SizedBox(height: 5),
        Text(accuracyLabel, style: kResultRatingTextStyle),
        const SizedBox(height: 5),
        Text(color, style: kResultTextStyle),
        const SizedBox(height: 5),
        Text(colorAccuracyLabel, style: kResultRatingTextStyle),
        const SizedBox(height: 5),
      ],
    );
  }
}
