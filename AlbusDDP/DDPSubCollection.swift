//
//  DDPSubCollection.swift
//  AlbusDDP
//
//  Created by Guillaume Elloy on 15/03/2017.
//  Copyright © 2017 Cleanio Services SAS. All rights reserved.
//

import Foundation


public protocol SubCollectionRunnable {
    func isDocumentFromSubCollection<T:DDPDocument>(document: T) -> Bool
}

open class DDPSubCollection<T:DDPDocument>: DDPCollection<T> {
    
    fileprivate var collection: DDPCollection<T>
    fileprivate var subCollectionRunnable: SubCollectionRunnable
    
    public init(fromCollection collection: DDPCollection<T>, subCollectionRunnable: SubCollectionRunnable) {
        self.collection = collection
        self.subCollectionRunnable = subCollectionRunnable
        super.init(named: collection.collectionName)
        
        self.collection.addCollectionListener(self)
        self.subCollection()
    }
    
    
    fileprivate func subCollection() {
        for document in self.collection {
            if self.subCollectionRunnable.isDocumentFromSubCollection(document: document) {
                self.add(document)
            }
        }
    }
    
    open func upsertDocument(withId documentId: String?) -> DDPUpdateType? {
        if  let documentId = documentId,
            let document = self.collection.find(withId: documentId) {
            let removed = self.remove(withId: documentId)
            if self.subCollectionRunnable.isDocumentFromSubCollection(document: document) {
                self.add(document)
                return removed ? .changed : .added
            }
            return removed ? .removed : nil
        }
        return nil
    }
    
    open func removeDocument(withId documentId: String?) {
        if let documentId = documentId {
            _ = self.remove(withId: documentId)
        }
    }
    
}


extension DDPSubCollection: DDPCollectionListener {
    
    public func onCollection<T:DDPDocument>(_ collection: DDPCollection<T>, updatedDocument documentId: String?, withUpdateType updateType: DDPUpdateType) {
        var opUpdateType: DDPUpdateType? = updateType
        switch updateType {
        case .added,
             .changed:
            opUpdateType = self.upsertDocument(withId: documentId)
            break
        case .removed:
            self.removeDocument(withId: documentId)
            break
        case .ready:
            self.onSubscriptionReady(self.collection.ready, error: nil)
            break
        }
        if opUpdateType != nil && opUpdateType! != .ready {
            self.notifyCollectionListenersDocument(withId: documentId, updatedWithType: updateType)
        }
    }
    
}
