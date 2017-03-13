//
//  DDPLog.swift
//  AlbusDDP
//
//  Created by Guillaume Elloy on 10/03/2017.
//  Copyright © 2017 Cleanio Services SAS. All rights reserved.
//

import Foundation

open class DDPLog {
    
    class public func p(_ tag: String, title: String, params: String...) {
        var message: String = title
        for param: String in params {
            message += (" | " + param)
        }
        DDPLog.p(tag, message: message)
    }
    
    class public func p(_ tag: String, message: String) {
        let formattedMessage = tag + " ### " + message
        print(formattedMessage)
    }
    
}
