//
//  UpdateGivingGoalCommand.swift
//  ios
//
//  Created by Mike Pattyn on 04/05/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation

class UpdateGivingGoalCommand : RequestProtocol {
    typealias TResponse = ResponseModel<Bool>

    var givingGoal: GivingGoal
    init(givingGoal: GivingGoal) {
        self.givingGoal = givingGoal
    }
}
