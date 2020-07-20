//
//  MediaterExtension.swift
//  ios
//
//  Created by Maarten Vergouwe on 20/07/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation
import UIKit

extension Mediater : MediaterWithContextProtocol {
    func send<R>(request: R, withContext context: UIViewController) throws -> (R.TResponse) where R : RequestProtocol {
        var response: R.TResponse!
        let semaphore = DispatchSemaphore.init(value: 1)
        try sendAsync(request: request, withContext: context) { innerResponse in
            response = innerResponse
            semaphore.signal()
        }
        semaphore.wait()
        return response
    }
    
    func sendAsync<R>(request: R, withContext context: UIViewController, completion: @escaping (R.TResponse) -> Void) throws where R : RequestProtocol {
        let handler = self.handlers.first { handler in
            if let handler = handler as? RequestHandlerWithContextProtocol {
                return handler.canHandle(request: request)
            }
            return false
        }
        if let handler = handler as? RequestHandlerWithContextProtocol {
            let requestPreProcessors = preProcessors.filter { proc in
                if let proc = proc as? RequestPreProcessorWithContextProtocol {
                    return proc.canHandle(request: request)
                }
                return false
            } as! [RequestPreProcessorWithContextProtocol]
                   
            let requestPostProcessors = postProcessors.filter { proc in
                if let proc = proc as? RequestPostProcessorWithContextProtocol {
                    return proc.canHandle(request: request)
                }
                return false
            } as! [RequestPostProcessorWithContextProtocol]
            
            var preCompletion = { (preResponse: R) throws in
                var postCompletion = { (postResponse: R.TResponse) throws in
                    completion(postResponse)
                }
                for postProc in requestPostProcessors.reversed() {
                    let nextCompletion = postCompletion
                    postCompletion = { postResponse in
                        try postProc.handle(request: preResponse, withContext: context, response: postResponse) { resp in
                            try nextCompletion(resp)
                        }
                    }
                }
                
                try handler.handle(request: preResponse, withContext: context) { response in
                    try postCompletion(response)
                }
            }
            
            for preProc in requestPreProcessors.reversed() {
                let nextCompletion = preCompletion
                preCompletion = { preResponse in
                    try preProc.handle(request: preResponse, withContext: context) { resp in
                        try nextCompletion(resp)
                    }
                }
            }
            
            try preCompletion(request)
        }
    }
}
