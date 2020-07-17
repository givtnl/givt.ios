//
//  File.swift
//  
//
//  Created by Maarten Vergouwe on 16/07/2020.
//

import Foundation

public protocol RequestProtocol {
    associatedtype TResponse
}

public class NoResponseRequest : RequestProtocol {
    public typealias TResponse = Void
}
