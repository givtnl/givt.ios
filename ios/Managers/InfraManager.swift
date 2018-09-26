//
//  InfraManager.swift
//  ios
//
//  Created by Lennie Stockman on 4/12/17.
//  Copyright © 2017 Givt. All rights reserved.
//

import Foundation
import AVFoundation
import LocalAuthentication

class InfraManager {
    static var shared = InfraManager()
    private let client = APIClient.shared
    private let log = LogService.shared
    private var device: AVCaptureDevice?
    private init() {
        
    }
    
    enum BiometricType {
        case none
        case touch
        case face
    }
    
    var timer: Timer?
    func flashTorch(length: Double, interval: Double) {
        guard let device = AVCaptureDevice.default(for: AVMediaType.video)
            else {return}
        self.device = device
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
            }
            catch {
                print("no can do torch")
            }
            timer = Timer.scheduledTimer(timeInterval: TimeInterval(interval), target: self, selector: #selector(toggle), userInfo: nil, repeats: true)

            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + length) {
                self.timer!.invalidate()
                self.device!.torchMode = .off
                self.device!.unlockForConfiguration()
            }
        } else {
            print("Torch is not available")
        }
    }
    
    static func biometricType() -> BiometricType {
        let authContext = LAContext()
        if #available(iOS 11, *) {
            var error: NSError?
            if authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                switch(authContext.biometryType) {
                case .none:
                    return .none
                case .touchID:
                    return .touch
                case .faceID:
                    return .face
                }
            } else {
                return .none
            }
        } else {
            return authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) ? .touch : .none
        }
    }
    
    @objc private func toggle() {
            if device!.torchMode == .off {
                device!.torchMode = .on
                AppServices.shared.vibrate()
            } else {
                device!.torchMode = .off
            }

    }
    
    private func checkForUpdates(callback: @escaping(Bool?) -> Void) {
        var appVersion: [String: String] = [:]
        appVersion["BuildNumber"] = AppConstants.buildNumber
        appVersion["DeviceOS"] = "1"
        do {
            try client.post(url: "/api/CheckForUpdate", data: appVersion) { (response) in
                if let response = response {
                    if response.basicStatus == .ok, let data = response.data, let text = response.text {
                        if text == "" {
                            callback(nil)
                            return
                        }
                        
                        do {
                            let parsedData = try JSONSerialization.jsonObject(with: data) as! [String: Any]
                            print(parsedData)
                            let dbBuildNumber = Int(truncating: parsedData["BuildNumber"] as! NSNumber)
                            if dbBuildNumber > Int(AppConstants.buildNumber)! {
                                //new build number
                                if Bool(truncating: parsedData["Critical"] as! NSNumber) {
                                    callback(true)
                                } else {
                                    callback(false)
                                }
                            }
                        } catch {
                            self.log.info(message: "could not parse json")
                        }
                    }
                } else {
                    self.log.warning(message: "No response from checkforupdates")
                }
            }
        } catch {
            log.warning(message: "Could not post to checkforupdate")
        }
        
    }
    
    func checkUpdates(callback: @escaping(Bool?) -> Void) {
        checkForUpdates { (status) in
            callback(status)
        }
    }    
}
