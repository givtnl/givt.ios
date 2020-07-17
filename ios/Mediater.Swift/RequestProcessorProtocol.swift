//
//  File.swift
//  
//
//  Created by Maarten Vergouwe on 16/07/2020.
//

import Foundation

public protocol RequestProcessorProtocol {
    func canHandle<R: RequestProtocol>(request: R) -> Bool
}
