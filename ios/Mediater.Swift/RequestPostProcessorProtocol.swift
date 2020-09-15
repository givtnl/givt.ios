//
//  File.swift
//  
//
//  Created by Maarten Vergouwe on 16/07/2020.
//

import Foundation

public protocol RequestPostProcessorProtocol : RequestProcessorProtocol {
    func handle<R: RequestProtocol>(request: R, response: R.TResponse, completion: @escaping(R.TResponse) throws -> Void) throws
}
