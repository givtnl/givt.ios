//
//  RequestHandlerProtocolExtension.swift
//  ios
//
//  Created by Maarten Vergouwe on 20/07/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation
import UIKit

protocol RequestHandlerWithContextProtocol : RequestHandlerProtocol {
    func handle<R: RequestProtocol>(request: R, withContext context: UIViewController, completion: @escaping(R.TResponse) throws -> Void) throws
}
