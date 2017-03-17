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
    
    open func add(_ document: T) {
        self.add(document, atIndex: self.documents.count)
    }
    
    open func add(_ document: T, atIndex index: Int) {
        self.documents.insert(document, at: index)
    }
    
    open func add(withId documentId: String?, andFields fields: JSONFields) {
        self.add(withId: documentId, andFields: fields, atIndex: self.documents.count)
    }
    
    open func add(withId documentId: String?, andFields fields: JSONFields, atIndex index: Int) {
        if documentId == nil || !self.update(withId: documentId!, updatedFields: fields) {
            if let document: T = T.build(documentId: documentId, documentFields: fields) {
                self.documents.insert(document, at: index)
            }
        }
    }
    
    open func update(withId documentId: String, updatedFields: JSONFields?) -> Bool {
        if let document = self.find(withId: documentId) {
            document.update(updatedFields: updatedFields)
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
        DDPLog.p("DDP", header: "### TEST ###", params: "ADD COLLECTION LISTENER")
        if self.indexForCollectionListener(listener: newListener) == nil {
            DDPLog.p("DDP", header: "### TEST ###", params: "ADDED COLLECTION LISTENER")
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
    
    public func notifyCollectionListenersDocument(withId documentId: String?, updatedWithType updateType: DDPUpdateType) {
        DDPLog.p("DDP", header: "### TEST ###", params: "NOTIFY COLLECTION LISTENER -------")
        for listener in self.collectionListeners {
            DDPLog.p("DDP", header: "### TEST ###", params: "NOTIFY COLLECTION LISTENER")
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
            if self.update(withId: documentId, updatedFields: updatedFields) {
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
    
    open func onSubscriptionReady(_ ready: Bool, error: Error?) {
        self.ready = ready
        DDPLog.p("DDP", header: "### TEST ###", params: "NOTIFY COLLECTION READY")
        self.notifyCollectionListenersDocument(withId: nil, updatedWithType: .ready)
    }
    
}

extension DDPCollection : Sequence {
    
    public func makeIterator() -> AnyIterator<T> {
        var nextIndex = self.documents.count
        return AnyIterator {
            nextIndex -= 1
            if (nextIndex < 0) {
                return nil
            }
            return self.documents[nextIndex]
        }
    }
    
}


