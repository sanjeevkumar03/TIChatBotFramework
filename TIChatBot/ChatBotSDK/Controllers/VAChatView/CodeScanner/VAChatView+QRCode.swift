//  VAChatView+QRCode.swift
// Copyright © 2021 Telus International. All rights reserved.

import UIKit
import AVFoundation
import Photos

extension VAChatViewController {

    func configureQRScannerView() {
        self.qrScannerView.delegate = self
        self.qrScannerContainerView.backgroundColor = .black.withAlphaComponent(0.35)

        self.qrScannerBackgroundView.layer.borderWidth = 2
        self.qrScannerBackgroundView.layer.borderColor = UIColor.systemGroupedBackground.cgColor
        self.qrScannerBackgroundView.layer.cornerRadius = 5.0

        self.uploadedQRCodeImageContainer.layer.borderWidth = 2.0
        self.uploadedQRCodeImageContainer.layer.cornerRadius = 2.0
        self.uploadedQRCodeImageContainer.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.35).cgColor

        self.uploadedQRCodeFromGalleryButton.layer.cornerRadius = 6.0
        self.uploadedQRCodeFromGalleryButton.layer.borderWidth = 1.0
        self.uploadedQRCodeFromGalleryButton.layer.borderColor = VAColorUtility.senderBubbleColor.cgColor
        self.uploadedQRCodeFromGalleryButton.backgroundColor = VAColorUtility.white
        self.uploadedQRCodeFromGalleryButton.setTitleColor(VAColorUtility.senderBubbleColor, for: .normal)
        self.uploadedQRCodeFromGalleryButton.titleLabel?.font = UIFont.systemFont(ofSize: textFontSize, weight: .medium)

        self.rescanQRCodeButton.layer.cornerRadius = 6.0
        self.rescanQRCodeButton.layer.borderWidth = 1.0
        self.rescanQRCodeButton.layer.borderColor = VAColorUtility.senderBubbleColor.cgColor
        self.rescanQRCodeButton.backgroundColor = VAColorUtility.white
        self.rescanQRCodeButton.setTitleColor(VAColorUtility.senderBubbleColor, for: .normal)
        self.rescanQRCodeButton.titleLabel?.font = UIFont.systemFont(ofSize: textFontSize, weight: .medium)
    }
    func localizeScannerView() {
        self.uploadedQRCodeFromGalleryButton.setTitle(LanguageManager.shared.localizedString(forKey: "Reupload QR Code"), for: .normal)
        self.rescanQRCodeButton.setTitle(LanguageManager.shared.localizedString(forKey: "Rescan QR Code"), for: .normal)
    }
    func showQRCodeScannerOptions() {
        let actionSheet = UIAlertController(title: nil, message: LanguageManager.shared.localizedString(forKey: "Please select option"), preferredStyle: .actionSheet)
        let scanAction = UIAlertAction(title: LanguageManager.shared.localizedString(forKey: "Scan QR Code"), style: .default) { _ in
            self.checkCameraUsagePermissions()
        }
        actionSheet.addAction(scanAction)
        let pickFromLibraryAction = UIAlertAction(title: LanguageManager.shared.localizedString(forKey: "Upload from Library"), style: .default) { _ in
            self.checkPhotoLibraryUsagePermissions()
        }
        actionSheet.addAction(pickFromLibraryAction)
        let cancelAction = UIAlertAction(title: LanguageManager.shared.localizedString(forKey: "Cancel"), style: .cancel) { _ in
        }
        actionSheet.addAction(cancelAction)
        self.present(actionSheet, animated: true)
    }

    func addQRScannerView(isQRCodeUploaded: Bool, image: UIImage? = nil, qrCodeValue: String = "") {
        self.sendQRCodeButton.isUserInteractionEnabled = true
        self.hideScannedQRCodeDescView()
        self.qrScannerContainerView.frame = self.view.bounds
        self.view.addSubview(self.qrScannerContainerView)
        if isQRCodeUploaded {
            self.qrScannerView.isHidden = true
            self.uploadedQRCodeContainer.isHidden = false
            self.uploadedQRCodeImageView.image = image
        } else {
            self.qrScannerView.isHidden = false
            self.uploadedQRCodeContainer.isHidden = true
        }
        if isQRCodeUploaded {
            if qrCodeValue.isEmpty {
                self.showQRCodeScanningError()
            } else {
                self.showScannedValue(scannedCode: qrCodeValue)
            }
        } else {
            if !qrCodeValue.isEmpty {
                self.showScannedValue(scannedCode: qrCodeValue)
            }
        }
        self.qrCodeValue = qrCodeValue
        self.qrCodeImage = image
        UIView.transition(with: view, duration: 0.25, options: .transitionCrossDissolve, animations: {
            self.view.bringSubviewToFront(self.qrScannerContainerView)
        })
    }
    func showScannedValue(scannedCode: String) {
        self.scannedCodeTitleLabel.text = "\(LanguageManager.shared.localizedString(forKey: "Scanned Code")):"
        self.scannedCodeTitleLabel.textColor = .black
        self.scannedCodeLabel.text = scannedCode
        self.scannedCodeLabel.textColor = .black
        self.scannedCodeDesStack.isHidden = false
        self.sendScannedCodeStack.isHidden = false
    }
    func hideScannedQRCodeDescView() {
        self.scannedCodeDesStack.isHidden = true
        self.sendScannedCodeStack.isHidden = true
    }
    func showQRCodeScanningError() {
        self.scannedCodeTitleLabel.text = "\(LanguageManager.shared.localizedString(forKey: "Error")):"
        self.scannedCodeTitleLabel.textColor = .red
        self.scannedCodeLabel.text = LanguageManager.shared.localizedString(forKey: "Uploaded QR Code is not valid. Please upload again.")
        self.scannedCodeLabel.textColor = .red
        self.scannedCodeDesStack.isHidden = false
    }
    func removeQRScannerView(isQRCodeUploaded: Bool = true) {
        if isQRCodeUploaded {
            self.hideUploadOptionsView()
        }
        UIView.transition(with: view, duration: 0.25, options: .transitionCrossDissolve, animations: {
            self.qrScannerContainerView.removeFromSuperview()
        })
    }
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 5, y: 5)
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        return nil
    }
    // MARK: Button Actions
    @IBAction func sendScannedQRCodeTapped(_ sender: UIButton) {
        self.sendQRCodeButton.isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            self.sendImageMessageToBot(image: self.qrCodeImage!, messageStr: self.qrCodeValue, messageType: SenderMessageType.qrCode)
            self.removeQRScannerView()
        }
    }
    @IBAction func uploadQRCodeFromGalleryTapped(_ sender: UIButton) {
        self.checkPhotoLibraryUsagePermissions()
    }
    @IBAction func rescanQRCodeTapped(_ sender: UIButton) {
        self.hideScannedQRCodeDescView()
        if !self.qrScannerView.isRunning {
            self.qrScannerView.startScanning()
        }
    }
    @IBAction func closeQRCodeViewTapped(_ sender: UIButton) {
        if self.qrScannerView.isRunning {
            self.qrScannerView.stopScanning()
        }
        self.removeQRScannerView(isQRCodeUploaded: false)
    }
}

// MARK: Camera usage permissions
extension VAChatViewController {
    func checkCameraUsagePermissions() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            switch authStatus {
            case .authorized:
                DispatchQueue.main.async {
                    self.openCameraPicker()
                }
            case .denied:
                self.requestCameraAccessFromSettings()
            case .notDetermined:
                self.showCameraAccessPermissionAlert()
            default:
                self.showCameraAccessPermissionAlert()
            }
        } else {
            let alertController = UIAlertController(title: LanguageManager.shared.localizedString(forKey: "Error"), message: LanguageManager.shared.localizedString(forKey: "Device has no camera"), preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: LanguageManager.shared.localizedString(forKey: "OK"), style: .default, handler: { (_) in
            })
            alertController.addAction(defaultAction)
            present(alertController, animated: true, completion: nil)
        }
    }

    func requestCameraAccessFromSettings() {
        let alert = UIAlertController(title: "", message: LanguageManager.shared.localizedString(forKey: "Please allow permission to use the Camera so that you can scan QR code."), preferredStyle: .alert )
        alert.addAction(UIAlertAction(title: LanguageManager.shared.localizedString(forKey: "Open Settings"), style: .default) { _ in
            if let appSettingsURL = NSURL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(appSettingsURL as URL)
            }
        })
        let declineAction = UIAlertAction(title: LanguageManager.shared.localizedString(forKey: "Not Now"), style: .cancel) { (_) in
        }
        alert.addAction(declineAction)
        present(alert, animated: true, completion: nil)
    }

    func showCameraAccessPermissionAlert() {
        if AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back).devices.count > 0 {
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { [weak self] granted in
                if granted {
                    DispatchQueue.main.async {
                        self?.openCameraPicker()
                    }
                }
            })
        }
    }

    func openCameraPicker() {
        self.addQRScannerView(isQRCodeUploaded: false)
        if self.qrScannerView.captureSession == nil {
            self.qrScannerView.setupCaptureSession()
        } else {
            self.qrScannerView.startScanning()
        }
    }
}

// MARK: Photo library usage permissions
extension VAChatViewController {
    func checkPhotoLibraryUsagePermissions() {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .authorized:
            DispatchQueue.main.async {
                self.openPhotoLibrary()
            }
        case .notDetermined:
            self.requestPhotoLibraryPermission()
        case .denied, .restricted:
            self.requestPhotoLibraryAccessFromSettings()
        case .limited:
            DispatchQueue.main.async {
                self.openPhotoLibrary()
            }
        @unknown default:
            self.requestPhotoLibraryPermission()
        }
    }

    func requestPhotoLibraryPermission() {
        PHPhotoLibrary.requestAuthorization({ (newStatus) in
            if newStatus ==  PHAuthorizationStatus.authorized {
                DispatchQueue.main.async {
                    self.openPhotoLibrary()
                }
            } else {
                debugPrint("User denied")
            }
        })
    }

    func requestPhotoLibraryAccessFromSettings() {
        let alert = UIAlertController(title: "", message: LanguageManager.shared.localizedString(forKey: "Please allow permission to access photos so that you can scan QR code."), preferredStyle: .alert )
        alert.addAction(UIAlertAction(title: LanguageManager.shared.localizedString(forKey: "Open Settings"), style: .default) { _ in
            if let appSettingsURL = NSURL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(appSettingsURL as URL)
            }
        })
        let declineAction = UIAlertAction(title: LanguageManager.shared.localizedString(forKey: "Not Now"), style: .cancel) { (_) in
        }
        alert.addAction(declineAction)
        present(alert, animated: true, completion: nil)
    }

    func openPhotoLibrary() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.mediaTypes = ["public.image"]
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }
}

// MARK: UIImagePickerControllerDelegate
extension VAChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard
            let qrcodeImg = info[.originalImage] as? UIImage,
            let detector: CIDetector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]),
            let ciImage: CIImage = CIImage(image: qrcodeImg),
            let features = detector.features(in: ciImage) as? [CIQRCodeFeature]
        else {
            print("Something went wrong")
            return
        }
        var qrCodeLink = ""
        features.forEach { feature in
            if let messageString = feature.messageString {
                qrCodeLink += messageString
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
            self.addQRScannerView(isQRCodeUploaded: true, image: qrcodeImg, qrCodeValue: qrCodeLink )
        }
        self.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        debugPrint("user cancelled selection")
    }
}

// MARK: QRScannerViewDelegate
extension VAChatViewController: QRScannerViewDelegate {
    func qrScanningDidFail() {
        debugPrint("QR code scanning failed")
    }

    func qrScanningSucceededWithCode(_ str: String?) {
        debugPrint("Scanned code: \(str ?? "")")
        let qrCodeImage = generateQRCode(from: str ?? "")
        self.addQRScannerView(isQRCodeUploaded: false, image: qrCodeImage, qrCodeValue: str ?? "")
    }

    func qrScanningDidStop() {
        debugPrint("QR code scanning stopped by user")
    }
}
