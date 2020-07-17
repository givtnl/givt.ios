//
//  File.swift
//  
//
//  Created by Maarten Vergouwe on 16/07/2020.
//

import Foundation

internal protocol MediaterProtocol {
    func registerPreProcessor<P: RequestPreProcessorProtocol>(processor: P)
    func registerHandler<H: RequestHandlerProtocol>(handler: H)
    func registerPostProcessor<P: RequestPostProcessorProtocol>(processor: P)
    
    func send<R: RequestProtocol>(request: R) throws -> (R.TResponse)
    func sendAsync<R: RequestProtocol>(request: R, completion: @escaping (R.TResponse) -> Void) throws
    
    var shared: MediaterProtocol { get }
}
