//
//  MediaterProtocolExtension.swift
//  ios
//
//  Created by Maarten Vergouwe on 20/07/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation
import UIKit

public protocol MediaterWithContextProtocol : MediaterProtocol {
    func send<R: RequestProtocol>(request: R, withContext context: UIViewController) throws -> (R.TResponse)
    func sendAsync<R: RequestProtocol>(request: R, withContext context: UIViewController, completion: @escaping (R.TResponse) -> Void) throws
}
