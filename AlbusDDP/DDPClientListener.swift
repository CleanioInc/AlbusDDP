//
//  DDPClientListener.swift
//  AlbusDDP
//
//  Created by Guillaume Elloy on 10/03/2017.
//  Copyright © 2017 Cleanio Services SAS. All rights reserved.
//


protocol DDPClientListener: class {
    func onCollection(named collectionName: String, addedDocument documentId: String, withFields fields: JSONFields)
    func onCollection(named collectionName: String, changedDocument documentId: String, withUpdatedFields updatedFields: JSONFields)
    func onCollection(named collectionName: String, removedDocument documentId: String)
}
