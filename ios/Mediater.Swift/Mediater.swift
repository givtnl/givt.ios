//
//  File.swift
//  
//
//  Created by Maarten Vergouwe on 16/07/2020.
//

import Foundation

final class Mediater : MediaterProtocol {
    static var shared = Mediater()

    var shared: MediaterProtocol { return Mediater.shared }
       
    var preProcessors = [Any]()
    var handlers = [Any]()
    var postProcessors = [Any]()
    
    func registerPreProcessor(processor: RequestProcessorProtocol) {
        preProcessors.append(processor)
    }
    
    func registerPostProcessor(processor: RequestProcessorProtocol) {
        postProcessors.append(processor)
    }
    
    func registerHandler(handler: RequestProcessorProtocol) {
        handlers.append(handler)
    }

    func send<R>(request: R) throws -> (R.TResponse) where R : RequestProtocol {
        var response: R.TResponse!
        let semaphore = DispatchSemaphore.init(value: 0)
        try sendAsync(request: request) { innerResponse in
            response = innerResponse
            semaphore.signal()
        }
        semaphore.wait()
        if response is ()? {
            if let _ = response as? Void {
                return () as! R.TResponse
            }
            let x: R.TResponse? = nil
            return x as! R.TResponse //ignore the warning because this is the only way we can allow optionals as return values for requests
        }
        if response == nil {
            throw MediaterError.handlerNotFound
        }
        return response
    }

    func sendAsync<R>(request: R, completion: @escaping (R.TResponse) -> Void) throws where R : RequestProtocol {
        let handler = self.handlers.first { handler in
            if let handler = handler as? RequestHandlerProtocol {
                return handler.canHandle(request: request)
            }
            return false
        }
        if let handler = handler as? RequestHandlerProtocol {
            let requestPreProcessors = preProcessors.filter { proc in
               if let proc = proc as? RequestPreProcessorProtocol {
                   return proc.canHandle(request: request)
               }
               return false
            } as! [RequestPreProcessorProtocol]
                   
            let requestPostProcessors = postProcessors.filter { proc in
                if let proc = proc as? RequestPostProcessorProtocol {
                    return proc.canHandle(request: request)
                }
                return false
            } as! [RequestPostProcessorProtocol]
            
            var preCompletion = { (preResponse: R) throws in
                var postCompletion = { (postResponse: R.TResponse) throws in
                    completion(postResponse)
                }
                for postProc in requestPostProcessors.reversed() {
                    let nextCompletion = postCompletion
                    postCompletion = { postResponse in
                        try postProc.handle(request: preResponse, response: postResponse) { resp in
                            try nextCompletion(resp)
                        }
                    }
                }
                
                try handler.handle(request: preResponse) { response in
                    try postCompletion(response)
                }
            }
            
            for preProc in requestPreProcessors.reversed() {
                let nextCompletion = preCompletion
                preCompletion = { preResponse in
                    try preProc.handle(request: preResponse) { resp in
                        try nextCompletion(resp)
                    }
                }
            }
            
            try preCompletion(request)
        }
    }
}
