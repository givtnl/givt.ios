//
//  BaseUser.swift
//  ios
//
//  Created by Maarten Vergouwe on 07/05/2018.
//  Copyright © 2018 Givt. All rights reserved.
//

import Foundation

class BaseUser: NSObject, NSCoding {
    var email: String = ""
    var guid: String = ""
    var isTemp: Bool = false
    
    override init() {}
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(guid, forKey: "guid")
        aCoder.encode(email, forKey: "email")
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.email = aDecoder.decodeObject(forKey: "email") as! String
        self.guid = aDecoder.decodeObject(forKey: "guid") as! String
    }
}
