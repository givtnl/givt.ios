//
//  ReponseModel.swift
//  ios
//
//  Created by Maarten Vergouwe on 12/10/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation

public class ResponseModel<T> {
    public var result : T
    public var error : ResponseError?
    public init (result: T, error: ResponseError? = nil) {
        self.result = result
        self.error = error
    }
}
