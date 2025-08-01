import SwiftUI
import AVFoundation
import CoreImage
import AudioToolbox

struct QRScanner: UIViewControllerRepresentable {
    let onScan: (String) -> Void
    
    func makeUIViewController(context: Context) -> QRScannerViewController {
        let viewController = QRScannerViewController()
        viewController.delegate = context.coordinator
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: QRScannerViewController, context: Context) {
        uiViewController.startScanning()
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, QRScannerViewControllerDelegate {
        let parent: QRScanner
        
        init(_ parent: QRScanner) {
            self.parent = parent
        }
        
        func didScanQRCode(_ code: String) {
            parent.onScan(code)
        }
    }
}

protocol QRScannerViewControllerDelegate: AnyObject {
    func didScanQRCode(_ code: String)
}

class QRScannerViewController: UIViewController {
    weak var delegate: QRScannerViewControllerDelegate?
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startScanning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopScanning()
    }
    
    private func setupCamera() {
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            print("Failed to get camera device")
            return
        }
        
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            print("Failed to create video input: \(error)")
            return
        }
        
        if captureSession?.canAddInput(videoInput) == true {
            captureSession?.addInput(videoInput)
        } else {
            print("Failed to add video input")
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if captureSession?.canAddOutput(metadataOutput) == true {
            captureSession?.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            print("Failed to add metadata output")
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        previewLayer?.frame = view.layer.bounds
        previewLayer?.videoGravity = .resizeAspectFill
        
        if let previewLayer = previewLayer {
            view.layer.addSublayer(previewLayer)
        }
        
        // Add scanning overlay
        addScanningOverlay()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }
    
    private func addScanningOverlay() {
        // Create scanning frame
        let scanningFrame = UIView()
        scanningFrame.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scanningFrame)
        
        NSLayoutConstraint.activate([
            scanningFrame.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scanningFrame.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            scanningFrame.widthAnchor.constraint(equalTo: view.widthAnchor),
            scanningFrame.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])
    }
    
    func startScanning() {
        DispatchQueue.global(qos: .background).async {
            self.captureSession?.startRunning()
        }
    }
    
    func stopScanning() {
        captureSession?.stopRunning()
    }
}

extension QRScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            delegate?.didScanQRCode(stringValue)
        }
    }
}

// MARK: - QR Code Detection from Image
struct QRCodeDetector {
    static func detectQRCode(in image: UIImage) -> String? {
        guard let ciImage = CIImage(image: image) else { return nil }
        
        let context = CIContext()
        let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: context, options: nil)
        
        let features = detector?.features(in: ciImage)
        
        for feature in features ?? [] {
            if let qrFeature = feature as? CIQRCodeFeature {
                return qrFeature.messageString
            }
        }
        
        return nil
    }
}

#Preview("QR Scanner Active") {
    QRScanner(
        onScan: {_ in }
    )
    .frame(height: 300)
}
