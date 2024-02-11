//
//  QRScreen.swift
//  VERO-Digital-Solutions-ios-task
//
//  Created by Şükrü Şimşek on 10.02.2024.
//

import UIKit
import AVFoundation

protocol QRViewInterface: AnyObject {
    func configureVC()
    func configureInputData()
    func configureQROutputData()
    func configurePreviewLayer()
}


class QRView: UIViewController {
    private let viewModel = QRViewModel()
    private var captureSession =  AVCaptureSession()
    let metadataOutput = AVCaptureMetadataOutput()
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.view = self
        viewModel.viewDidLoad()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (captureSession.isRunning == false) {
            DispatchQueue.global(qos: .background).async {
                self.captureSession.startRunning()
            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if (captureSession.isRunning == true) {
            captureSession.stopRunning()
            
        }
    }


}
extension QRView: QRViewInterface, AVCaptureMetadataOutputObjectsDelegate {
    func configureVC() {
        view.backgroundColor = .black
        
    }
    //Control the input data for QR
    func configureInputData() {
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        guard let inputData = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        if captureSession.canAddInput(inputData) {
            captureSession.addInput(inputData)
        } else {
            alert(message: "Error Found: Data process has a problem.")
            captureSession.stopRunning()
            return
        }
    }
    //Control the data output for QR to text.
    func configureQROutputData() {
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr,.ean8,.ean13, .pdf417]
        } else {
            alert(message: "Error Found: QR solving has a problem.")
            captureSession.stopRunning()
            return
        }
    }
    func configurePreviewLayer() {
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        captureSession.startRunning()
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
            captureSession.stopRunning()
            dismiss(animated: true)
        }
        
    }//Post for text in QR
    private func found(code: String) {
        NotificationCenter.default.post(name: .QRName, object: code)
    }
    
}
