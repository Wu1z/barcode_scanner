import 'package:barcode_reader/repositories/repository.dart';
import 'package:barcode_reader/view/saved_codes_page.dart';
import 'package:barcode_reader/widgets/confirm_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QrCodePage extends StatefulWidget {
  const QrCodePage({Key? key}) : super(key: key);

  @override
  State<QrCodePage> createState() => _QrCodePageState();
}

class _QrCodePageState extends State<QrCodePage> {
  
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  final repository = Repository(FirebaseFirestore.instance);
  
  QRViewController? _controller;
  Barcode? _result;
  bool _flashOn = false;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Container(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              icon: _flashOn 
                ? const Icon(Icons.flash_on, color: Colors.yellow)
                : const Icon(Icons.flash_off, color: Colors.grey),
              onPressed: () {
                _onFlash();
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              icon: const Icon(Icons.menu, color: Colors.grey),
              onPressed: () {
                _goToSavedPage(null);
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: QRView(
              overlay: QrScannerOverlayShape(
                borderColor: const Color(0xFF00DB0B), 
                borderRadius: 10, 
                borderLength: 30, 
                borderWidth: 10, 
                cutOutSize: 300,
              ),
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),  
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    _controller = controller;
    _controller?.resumeCamera();
    controller.scannedDataStream.listen((scanData) {
      if(scanData.code != null && scanData.code!.isNotEmpty){
        controller.pauseCamera();
        setState(() {
          _result = scanData;
        });
        _showConfirmDialog();
      }
    });
  }

  void _onFlash() {
    _controller?.toggleFlash();
    setState(() {
      _flashOn = !_flashOn;
    });
  }

  void _showConfirmDialog() {
    showDialog(
      context: context, 
      builder: (_) {
        return ConfirmDialog(
          titulo: "Attention", 
          descricao: "Save the content from the code?", 
          onConfirm: () {
            Navigator.pop(context);
            _goToSavedPage(_result);
          },
        );
      }
    ).then((value) {
      _controller?.resumeCamera();
    });
  }

  void _goToSavedPage(Barcode? barcode) {
    _insert(barcode);
    final route = MaterialPageRoute(
      builder: (context) => const SavedCodePage(),
    );
    Navigator.push(context, route);
  }

  Future<void> _insert(Barcode? barcode) async {
    if(barcode != null && barcode.code != null) {
      await repository.insert(barcode.code!);
    }
  }
}