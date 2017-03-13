//
//  ExMETDDPConnectionStatus.swift
//  AlbusDDP
//
//  Created by Guillaume Elloy on 11/05/16.
//  Copyright © 2016 Guillaume Elloy. All rights reserved.
//

import Meteor

extension METDDPConnectionStatus: CustomStringConvertible {
    public var description: String {
        switch self {
        case .offline:
            return "Offline"
        case .connecting:
            return "Connecting"
        case .connected:
            return "Connected"
        case .waiting:
            return "Waiting"
        case .failed:
            return "Failed"
        }
    }
}
