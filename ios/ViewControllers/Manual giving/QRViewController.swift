//
//  QRViewController.swift
//  ios
//
//  Created by Lennie Stockman on 3/11/17.
//  Copyright © 2017 Givt. All rights reserved.
//

import UIKit
import AVFoundation

class QRViewController: BaseScanViewController, AVCaptureMetadataOutputObjectsDelegate {
    @IBOutlet var containerVIew: UIView!
    private var log = LogService.shared
    @IBOutlet var subTitle: UILabel!
    @IBOutlet var navBar: UINavigationItem!
    @IBOutlet weak var topLeft: UIImageView!
    @IBOutlet var topRight: UIImageView!
    @IBOutlet var bottomLeft: UIImageView!
    @IBOutlet var bottomRight: UIImageView!
    @IBOutlet weak var backButton: UIBarButtonItem!
    var video : AVCaptureVideoPreviewLayer? = nil
    var session : AVCaptureSession? = nil
    @IBOutlet var qrView: UIView!
    private var isCameraDisabled = false
    override func viewDidLoad() {
        super.viewDidLoad()
        backButton.accessibilityLabel = NSLocalizedString("Back", comment: "")
        navBar.title = NSLocalizedString("GiveDifferentScan", comment: "")
        subTitle.text = NSLocalizedString("GiveDiffQRText", comment: "")
        topRight.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
        bottomRight.transform = CGAffineTransform(rotationAngle: (180.0 * CGFloat(Double.pi)) / 180.0)
        bottomLeft.transform = CGAffineTransform(rotationAngle: (270.0 * CGFloat(Double.pi)) / 180.0)
        
        log.info(message: "QR Page is shown")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        GivtService.shared.delegate = self
        
        #if DEBUG
        if TARGET_OS_SIMULATOR != 0 {
            return
        }
        #endif
        
        
        if let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) {
            do {
                session = AVCaptureSession()
                video = AVCaptureVideoPreviewLayer()
                let input = try AVCaptureDeviceInput(device: captureDevice)
                session!.addInput(input)
                let output = AVCaptureMetadataOutput()
                session!.addOutput(output)
                
                output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                
                output.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
                
                video! = AVCaptureVideoPreviewLayer(session: session!)
                video!.videoGravity = AVLayerVideoGravity.resizeAspectFill
                video!.frame = containerVIew.layer.bounds
                
                containerVIew.layer.addSublayer(video!)
                session!.startRunning()
            } catch {
                print("camera does not work")
                isCameraDisabled = true
            }
        } else {
            isCameraDisabled = true
        }
        
        if isCameraDisabled {
            let overlay: UIView = UIView(frame: CGRect(x: 0, y: 0, width: containerVIew.frame.size.width, height: containerVIew.frame.size.height))
            overlay.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.1)
            containerVIew.addSubview(overlay)
            containerVIew.bringSubview(toFront: overlay)
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            })
            let alert = UIAlertController(title: "", message: NSLocalizedString("NoCameraAccess", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OpenSettings", comment: ""), style: .default, handler: { (action) in
                guard let url = URL(string: UIApplicationOpenSettingsURLString) else { return }
                UIApplication.shared.openURL(url)
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                self.navigationController?.popViewController(animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
        } else {
            containerVIew.bringSubview(toFront: topLeft)
            containerVIew.bringSubview(toFront: topRight)
            containerVIew.bringSubview(toFront: bottomLeft)
            containerVIew.bringSubview(toFront: bottomRight)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        GivtService.shared.delegate = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count > 0 {
            if let object = metadataObjects[0] as? AVMetadataMachineReadableCodeObject {
                if object.type == AVMetadataObject.ObjectType.qr {
                    session!.stopRunning()
                    self.log.info(message: "Scanned a QR")
                    giveManually(scanResult: object.stringValue!)
                }
            }
        }
    }
    
    func giveManually(scanResult: String) {
        GivtService.shared.giveQR(scanResult: scanResult, completionHandler: { success in
            if !success {
                self.log.warning(message: "Could not scan QR: " + scanResult )
                let alert = UIAlertController(title: NSLocalizedString("SomethingWentWrong", comment: ""), message: NSLocalizedString("CodeCanNotBeScanned", comment: ""), preferredStyle: .alert)
                let action = UIAlertAction(title: NSLocalizedString("TryAgain", comment: ""), style: .default) { (ok) in
                    self.session!.startRunning()
                }
                let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { (nok) in
                    self.navigationController?.popViewController(animated: true)
                }
                alert.addAction(action)
                alert.addAction(cancel)
                self.present(alert, animated: true, completion: nil)
            }
        })
    }

}
