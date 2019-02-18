import UIKit
import AVFoundation
import QRCodeReader

class QRScaner: QRCodeReaderViewControllerDelegate {
    
    var finalHandler = {}
    var code = ""
    func start(_ vc: ViewController){
        // Retrieve the QRCode content
        // By using the delegate pattern
        readerVC.delegate = self
        // Or by using the closure pattern
        readerVC.completionBlock = { (result: QRCodeReaderResult?) in
            self.code = (result?.value) ?? ""
            print(result ?? "No Result")
        }
        // Presents the readerVC as modal form sheet
        readerVC.modalPresentationStyle = .formSheet
        
        vc.present(readerVC, animated: true, completion: nil)
    }
    // Good practice: create the reader lazily to avoid cpu overload during the
    // initialization and each time we need to scan a QRCode
    lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
        }
        return QRCodeReaderViewController(builder: builder)
    }()
    
    // MARK: - QRCodeReaderViewController Delegate Methods
    
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()
        readerVC.dismiss(animated: true){
            self.finalHandler()
        }
    }
    
    //This is an optional delegate method, that allows you to be notified when the user switches the cameraName
    //By pressing on the switch camera button
    func reader(_ reader: QRCodeReaderViewController, didSwitchCamera newCaptureDevice: AVCaptureDeviceInput) {
        let cameraName = newCaptureDevice.device.localizedName
        print("Switching capturing to: \(cameraName)")
    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        readerVC.dismiss(animated: true){
            self.finalHandler()
        }
    }
}
