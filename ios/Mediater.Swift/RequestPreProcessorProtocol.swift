//
//  File.swift
//  
//
//  Created by Maarten Vergouwe on 16/07/2020.
//

import Foundation

public protocol RequestPreProcessorProtocol : RequestProcessorProtocol {
    func handle<R: RequestProtocol>(request: R, completion: @escaping(R) throws -> Void) throws
}
