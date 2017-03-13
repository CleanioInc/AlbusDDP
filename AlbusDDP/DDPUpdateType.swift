//
//  DDPUpdateType.swift
//  AlbusDDP
//
//  Created by Guillaume Elloy on 10/03/2017.
//  Copyright © 2017 Cleanio Services SAS. All rights reserved.
//

import Foundation


typealias JSONFields = [String: Any]

enum DDPUpdateType {
    case added, changed, removed, ready
}
