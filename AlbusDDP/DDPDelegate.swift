//
//  MeteorDelegate.swift
//  AlbusDDP
//
//  Created by Guillaume Elloy on 10/03/2017.
//  Copyright © 2017 Cleanio Services SAS. All rights reserved.
//

import Foundation
import Meteor

open class DDPDelegate {
    
    fileprivate var clientListeners: [DDPClientListener]
    fileprivate var serverURL: URL
    fileprivate var meteorClient: METDDPClient!
    
    
    public init(serverURL: URL) {
        self.clientListeners = [DDPClientListener]()
        self.serverURL = serverURL
        self.meteorClient = self.initClient()
    }
    
    fileprivate func initClient() -> METDDPClient {
        let client = METDDPClient(serverURL: self.serverURL)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(DDPDelegate.meteorClientConnectionStatusDidChanged),
                                               name: NSNotification.Name.METDDPClientDidChangeConnectionStatus,
                                               object: client)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(DDPDelegate.meteorDatabaseDidChange(_:)),
                                               name: NSNotification.Name.METDatabaseDidChange,
                                               object: client.database)
        return client
    }
    
    fileprivate func deinitClient(onFinish: (() -> Void)?) {
        self.meteorClient.logout(completionHandler:
            DDPListeners.logoutListener(onSuccess: nil,
                                        onError: nil,
                                        onFinish: {
                                            self.meteorClient.disconnect()
                                            NotificationCenter.default.removeObserver(self)
                                            if let onFinish = onFinish {
                                                onFinish()
                                            }
            }))
    }
    
    open func getClient() -> METDDPClient {
        return self.meteorClient
    }
    
    open func connectClient() {
        self.meteorClient.connect()
    }
    
    open func reconnectClient() {
        if self.meteorClient.isConnected {
            self.deinitClient(onFinish: {
                self.meteorClient = self.initClient()
                self.connectClient()
            })
        } else {
            self.meteorClient = self.initClient()
            self.connectClient()
        }
    }

    
    //MARK: -SUBSCRIPTIONS HELPERS
    
    open func addSubscription<T:DDPDocument>(named subscriptionName: String, forCollections collections: DDPCollection<T>...) {
        for collection in collections {
            self.addClientListener(collection)
        }
        self.meteorClient.addSubscription(withName: subscriptionName, completionHandler:
            DDPListeners.subscriptionListener(named: subscriptionName,
                                              onSuccess: { (Void) in
                                                self.notifySubscriptionReady(withError: nil, forCollections: collections)
            },
                                              onError: { (error: Error) in
                                                self.notifySubscriptionReady(withError: nil, forCollections: collections)
            },
                                              onFinish: nil))
    }
    
    fileprivate func notifySubscriptionReady<T:DDPDocument>(withError error: Error?, forCollections collections: [DDPCollection<T>]) {
        for collection in collections {
            collection.onSubscriptionReady(true, error: error)
        }
    }
    
    
    func upcast<T, U>(bla: T) -> U? {
        return bla as? U
    }
    
    
    //MARK: - LISTENERS HELPERS
    
    open func addClientListener(_ newListener: DDPClientListener) {
        if self.indexForClientListener(listener: newListener) == nil {
            self.clientListeners.append(newListener)
        }
    }
    
    open func removeClientListener(_ oldListener: DDPClientListener) {
        if let index = self.indexForClientListener(listener: oldListener) {
            self.clientListeners.remove(at: index)
        }
    }
    
    fileprivate func indexForClientListener(listener: DDPClientListener) -> Int? {
        for i in 0..<self.clientListeners.count {
            if self.clientListeners[i] === listener {
                return i
            }
        }
        return nil
    }

    
    //MARK: - SELECTORS
    
    @objc open func meteorClientConnectionStatusDidChanged() {
        DDPLog.p(DDPLog.kLogTag, header: DDPLog.kLogHeaderConnection, params: self.meteorClient.connectionStatus.description)
    }
    
    
    @objc open func meteorDatabaseDidChange(_ notification: Notification) {
        if  let userInfo = (notification as NSNotification).userInfo,
            let databaseChanges = userInfo[METDatabaseChangesKey] as? METDatabaseChanges {
        
            databaseChanges.enumerateDocumentChangeDetails() { (documentChangeDetails, unsafeMutablePointerBool) in
                let changeTypeName: String = documentChangeDetails.changeType.description
                let collectionName: String = documentChangeDetails.documentKey.collectionName
                let documentId: String = documentChangeDetails.documentKey.documentID as! String
                DDPLog.p(DDPLog.kLogTag, header: changeTypeName, params: collectionName, documentId)
                
                for clientListener in self.clientListeners {
                    switch(documentChangeDetails.changeType) {
                    case .add:
                        if let fields = documentChangeDetails.changedFields as? JSONFields {
                            clientListener.onCollection(named: collectionName, addedDocument: documentId, withFields: fields)
                        }
                        break
                    case .update:
                        if let updatedFields = documentChangeDetails.changedFields as? JSONFields {
                            clientListener.onCollection(named: collectionName, changedDocument: documentId, withUpdatedFields: updatedFields)
                        }
                        break
                    case .remove:
                        clientListener.onCollection(named: collectionName, removedDocument: documentId)
                        break
                    }
                }
            }
        }
    }
    
}
