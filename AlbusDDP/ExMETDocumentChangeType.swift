//
//  ExMETChangeType.swift
//  AlbusDDP
//
//  Created by Guillaume Elloy on 07/07/16.
//  Copyright © 2016 Guillaume Elloy. All rights reserved.
//

import Meteor

extension METDocumentChangeType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .add:
            return "ADDED"
        case .remove:
            return "REMOVED"
        case .update:
            return "CHANGED"
        }
    }
}
