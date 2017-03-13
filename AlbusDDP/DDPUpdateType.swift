//
//  DDPUpdateType.swift
//  AlbusDDP
//
//  Created by Guillaume Elloy on 10/03/2017.
//  Copyright © 2017 Cleanio Services SAS. All rights reserved.
//

import Foundation


public typealias JSONFields = [String: Any]

public enum DDPUpdateType {
    case added, changed, removed, ready
}
