//
//  Message.swift
//  Messaging
//
//  Created by A on 18.05.2020.
//  Copyright © 2020 test. All rights reserved.
//

import UIKit
import Firebase

class Message: NSObject {
    var fromId: String?
    var text: String?
    var timestamp: NSNumber?
    var toId: String?
    
    func chatPartherId() -> String? {
        return fromId == Auth.auth().currentUser?.uid ? toId : fromId
    }
}
