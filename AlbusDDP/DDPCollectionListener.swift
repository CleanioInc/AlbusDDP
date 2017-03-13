//
//  DDPCollectionListener.swift
//  AlbusDDP
//
//  Created by Guillaume Elloy on 10/03/2017.
//  Copyright © 2017 Cleanio Services SAS. All rights reserved.
//


public protocol DDPCollectionListener: class {
    func onCollection<T:DDPDocument>(_ collection: DDPCollection<T>, updatedDocument documentId: String?, withUpdateType updateType: DDPUpdateType);
}
