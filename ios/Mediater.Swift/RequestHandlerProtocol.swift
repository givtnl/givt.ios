//
//  File.swift
//  
//
//  Created by Maarten Vergouwe on 16/07/2020.
//

import Foundation

public protocol RequestHandlerProtocol : RequestProcessorProtocol {
    func handle<R: RequestProtocol>(request: R, completion: @escaping(R.TResponse) throws -> Void) throws
}
