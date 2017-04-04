//
//  DDPLog.swift
//  AlbusDDP
//
//  Created by Guillaume Elloy on 10/03/2017.
//  Copyright © 2017 Cleanio Services SAS. All rights reserved.
//

import Foundation

open class DDPLog {
    
    open static let kLogTag: String = "DDP"
    open static let kLogHeaderConnection: String = "CONNECTION STATUS"
    open static let kLogHeaderLogin: String = "LOGIN"
    open static let kLogHeaderLogout: String = "LOGOUT"
    open static let kLogHeaderMethod: String = "METHOD"
    open static let kLogHeaderSubscription: String = "SUBSCRIPTION"
    open static let kLogResultSuccess: String = "SUCCESS"
    open static let kLogResultError: String = "ERROR"
    
    open static var logListener: ((String) -> Void)?
    
    
    open class func p(_ tag: String, header: String, params: String...) {
        var message: String = header
        for param: String in params {
            message += (" | " + param)
        }
        DDPLog.p(tag, message: message)
    }
    
    open class func p(_ tag: String, message: String) {
        let formattedMessage = tag + " ### " + message
        print(formattedMessage)
        if let logListener = DDPLog.logListener {
            logListener(formattedMessage)
        }
    }
    
}
