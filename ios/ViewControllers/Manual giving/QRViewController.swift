//
//  QRViewController.swift
//  ios
//
//  Created by Lennie Stockman on 3/11/17.
//  Copyright © 2017 Givt. All rights reserved.
//

import UIKit
import AVFoundation

class QRViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    private var log = LogService.shared
    @IBOutlet var subTitle: UILabel!
    @IBOutlet var navBar: UINavigationItem!
    @IBOutlet var topRight: UIImageView!
    @IBOutlet var bottomLeft: UIImageView!
    @IBOutlet var bottomRight: UIImageView!
    var video = AVCaptureVideoPreviewLayer()
    let session = AVCaptureSession()
    @IBOutlet var qrView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        navBar.title = NSLocalizedString("GiveDifferentScan", comment: "")
        subTitle.text = NSLocalizedString("GiveDiffQRText", comment: "")
        topRight.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
        bottomRight.transform = CGAffineTransform(rotationAngle: (180.0 * CGFloat(Double.pi)) / 180.0)
        bottomLeft.transform = CGAffineTransform(rotationAngle: (270.0 * CGFloat(Double.pi)) / 180.0)
        
        //capture device
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            session.addInput(input)
        } catch {
            print("camera does not work")
        }
        
        let output = AVCaptureMetadataOutput()
        session.addOutput(output)
        
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        
        output.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        
        video = AVCaptureVideoPreviewLayer(session: session)
        video.videoGravity = AVLayerVideoGravity.resizeAspectFill
        video.frame = qrView.bounds
        
        qrView.layer.addSublayer(video)
        session.startRunning()
        
        log.info(message: "QR Page is shown")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count > 0 {
            if let object = metadataObjects[0] as? AVMetadataMachineReadableCodeObject {
                if object.type == AVMetadataObject.ObjectType.qr {
                    session.stopRunning()
                    self.log.info(message: "Scanned a QR")
                    giveManually(scanResult: object.stringValue!)
                }
            }
        }
    }
    
    func giveManually(scanResult: String) {
        GivtService.shared.giveQR(scanResult: scanResult) { (success) in
            if !success {
                self.log.warning(message: "Could not scan QR: " + scanResult )
                let alert = UIAlertController(title: NSLocalizedString("SomethingWentWrong", comment: ""), message: NSLocalizedString("CodeCanNotBeScanned", comment: ""), preferredStyle: .alert)
                let action = UIAlertAction(title: NSLocalizedString("TryAgain", comment: ""), style: .default) { (ok) in
                    self.session.startRunning()
                }
                let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { (nok) in
                    self.navigationController?.popViewController(animated: true)
                }
                alert.addAction(action)
                alert.addAction(cancel)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
