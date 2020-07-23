//
//  File.swift
//  
//
//  Created by Maarten Vergouwe on 16/07/2020.
//

import Foundation

public protocol MediaterProtocol {
    var shared: MediaterProtocol { get }
    func registerPreProcessor(processor: RequestProcessorProtocol)
    func registerHandler(handler: RequestProcessorProtocol)
    func registerPostProcessor(processor: RequestProcessorProtocol)
    
    func send<R: RequestProtocol>(request: R) throws -> (R.TResponse)
    func sendAsync<R: RequestProtocol>(request: R, completion: @escaping (R.TResponse) -> Void) throws
}
