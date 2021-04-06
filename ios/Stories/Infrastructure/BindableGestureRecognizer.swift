//
//  BindableGestureRecognizer.swift
//  ios
//
//  Created by Mike Pattyn on 09/03/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import UIKit
final class BindableGestureRecognizer: UITapGestureRecognizer {
    private var action: () -> Void

    init(action: @escaping () -> Void) {
        self.action = action
        super.init(target: nil, action: nil)
        self.addTarget(self, action: #selector(execute))
    }

    @objc private func execute() {
        action()
    }
}
