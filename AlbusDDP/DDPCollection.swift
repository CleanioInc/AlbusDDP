//
//  DDPCollection.swift
//  AlbusDDP
//
//  Created by Guillaume Elloy on 10/03/2017.
//  Copyright © 2017 Cleanio Services SAS. All rights reserved.
//

import Foundation


open class DDPCollection<T:DDPDocument> {

    
    fileprivate var documents: [T]
    fileprivate var collectionListeners: [DDPCollectionListener]
    
    open var collectionName: String
    open var ready: Bool
    
    public init(named collectionName: String) {
        self.documents = [T]()
        self.collectionListeners = [DDPCollectionListener]()
        self.collectionName = collectionName
        self.ready = false
    }
    
    
    open func add(withId documentId: String?, andFields fields: JSONFields) {
        self.add(atIndex: self.documents.count, withId: documentId, andFields: fields)
    }
    
    open func add(atIndex index: Int, withId documentId: String?, andFields fields: JSONFields) {
        if documentId == nil || !self.update(withId: documentId!, updatedFields: fields, removedFields: nil) {
            if let document: T = T.build(documentId: documentId, documentFields: fields) {
                self.documents.insert(document, at: index)
            }
        }
    }
    
    open func update(withId documentId: String, updatedFields: JSONFields?, removedFields: String?) -> Bool {
        if let document = self.find(withId: documentId) {
            document.update(updatedFields: updatedFields, removedFields: removedFields, type: T.self)
            return true
        }
        return false
    }
    
    open func remove(withId documentId: String) -> Bool {
        if  let document = self.find(withId: documentId),
            let documentIndex = self.documents.index(of: document) {
            self.documents.remove(at: documentIndex)
            return true
        }
        return false
    }
    
    open func find(withId documentId: String) -> T? {
        for document in self.documents {
            if document.id != nil && document.id == documentId {
                return document
            }
        }
        return nil
    }
    
    
    //MARK: - DDPCollectionListener
    
    open func addCollectionListener(_ newListener: DDPCollectionListener) {
        if self.indexForCollectionListener(listener: newListener) == nil {
            self.collectionListeners.append(newListener)
        }
    }
    
    open func removeCollectionListener(_ oldListener: DDPCollectionListener) {
        if let index = self.indexForCollectionListener(listener: oldListener) {
            self.collectionListeners.remove(at: index)
        }
    }
    
    fileprivate func indexForCollectionListener(listener: DDPCollectionListener) -> Int? {
        for i in 0..<self.collectionListeners.count {
            if self.collectionListeners[i] === listener {
                return i
            }
        }
        return nil
    }
    
    fileprivate func notifyCollectionListenersDocument(withId documentId: String?, updatedWithType updateType: DDPUpdateType) {
        for listener in self.collectionListeners {
            listener.onCollection(self, updatedDocument: documentId, withUpdateType: updateType)
        }
    }
    
    
}

extension DDPCollection : DDPClientListener {
    
    open func onCollection(named collectionName: String, addedDocument documentId: String, withFields fields: JSONFields) {
        if self.collectionName == collectionName {
            self.add(withId: documentId, andFields: fields)
            self.notifyCollectionListenersDocument(withId: documentId, updatedWithType: .added)
        }
    }
    
    open func onCollection(named collectionName: String, changedDocument documentId: String, withUpdatedFields updatedFields: JSONFields) {
        if self.collectionName == collectionName {
            if self.update(withId: documentId, updatedFields: updatedFields, removedFields: nil) {
                self.notifyCollectionListenersDocument(withId: documentId, updatedWithType: .changed)
            }
        }
    }
    
    open func onCollection(named collectionName: String, removedDocument documentId: String) {
        if self.collectionName == collectionName {
            if self.remove(withId: documentId) {
                self.notifyCollectionListenersDocument(withId: documentId, updatedWithType: .removed)
            }
        }
    }

}

extension DDPCollection : DDPSubscriptionListener {
    
    open func onSubscriptionReady(_ ready: Bool) {
        self.ready = ready
        self.notifyCollectionListenersDocument(withId: nil, updatedWithType: .ready)
    }
    
}

extension DDPCollection : Sequence {
    
    public func makeIterator() -> AnyIterator<T> {
        var nextIndex = self.documents.count - 1
        return AnyIterator {
            if (nextIndex < 0) {
                return nil
            }
            nextIndex -= 1
            return self.documents[nextIndex]
        }
    }
    
}


