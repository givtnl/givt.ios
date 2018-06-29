//
//  LogService.swift
//  ios
//
//  Created by Lennie Stockman on 28/11/17.
//  Copyright © 2017 Givt. All rights reserved.
//

import Foundation
import SwiftClient

final class LogService: ILogService {
    
    func debug(message: String, method: String = #function, file: String = #file, linenr: Int = #line) {
        print("🔧 ", terminator: "")
        self.log(logLevel: .debug, message: message, method: method, file: file, linenr: linenr)
    }
    
    func info(message: String, method: String = #function, file: String = #file, linenr: Int = #line) {
        print("ℹ️ ", terminator: "")
        self.log(logLevel: .info, message: message, method: method, file: file, linenr: linenr)
    }
    
    func warning(message: String, method: String = #function, file: String = #file, linenr: Int = #line) {
        print("⚠️ ", terminator: "")
        self.log(logLevel: .warning, message: message, method: method, file: file, linenr: linenr)
    }
    
    func error(message: String, method: String = #function, file: String = #file, linenr: Int = #line) {
        print("🚩 ", terminator: "")
        self.log(logLevel: .error, message: message, method: method, file: file, linenr: linenr)
    }
    
    private func log(logLevel: LogLevel, message: String, method: String, file: String, linenr: Int) {
        print(message)
        let data = [ "email" : (UserDefaults.standard.userExt != nil) ? UserDefaults.standard.userExt!.email : "user with no email",
                    "file" : NSURL(fileURLWithPath: file).lastPathComponent,
                    "level" : logLevel.rawValue,
                    "lnr" : String(describing: linenr),
                    "message" : message,
                    "method" : method,
                    "model" : String(describing: UIDevice.current.modelName),
                    "tag" : LogService.ENVIRONMENT,
                    "appVersion" : String(describing: AppConstants.AppVersionNumber),
                    "versionOS" : String(describing: UIDevice.current.systemName + " " + UIDevice.current.systemVersion),
                    "lang" : Locale.preferredLanguages[0]]
        
        client.post(url: "/v2")
            .send(data: data)
            .set(headers: ["Content-Type" : "application/json", "ApiKey": LogService.KEY])
            .end(done: { (res: Response) -> Void in
                //print(String(describing: res.text))
                if res.basicStatus == .ok {
                    
                } else {
                    
                }
            })
    }

    static let shared = LogService()
    
    static let URL: String = "https://api.logit.io"
    static let KEY: String = "73b6d8f0-132f-45ff-a8cf-6654ffee1922"
    private var client = Client().baseUrl(url: URL)
    static var ENVIRONMENT: String {
        get {
            #if PRODUCTION
                return "GivtApp.iOS.Production"
            #else
                return "GivtApp.iOS.Debug"
            #endif
        }
    }
    
    private init() {
    }
}


public enum LogLevel: String {
    case debug
    case info
    case warning
    case error
}

