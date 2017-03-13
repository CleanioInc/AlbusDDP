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
    
    open let meteorClient: METDDPClient
    
    public init(serverURL: URL) {
        self.clientListeners = [DDPClientListener]()
        self.meteorClient = METDDPClient(serverURL: serverURL)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(DDPDelegate.meteorClientConnectionStatusDidChanged),
                                               name: NSNotification.Name.METDDPClientDidChangeConnectionStatus,
                                               object: self.meteorClient)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(DDPDelegate.meteorDatabaseDidChange(_:)),
                                               name: NSNotification.Name.METDatabaseDidChange,
                                               object: self.meteorClient.database)
    }
    
    
    
    
    //MARK: - HELPERS
    
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
        DDPLog.p("DDP", message: "CONNECTION STATUS : " + self.meteorClient.connectionStatus.description)
    }
    
    
    @objc open func meteorDatabaseDidChange(_ notification: Notification) {
        if  let userInfo = (notification as NSNotification).userInfo,
            let databaseChanges = userInfo[METDatabaseChangesKey] as? METDatabaseChanges {
        
            databaseChanges.enumerateDocumentChangeDetails() { (documentChangeDetails, unsafeMutablePointerBool) in
                let changeTypeName: String = documentChangeDetails.changeType.description
                let collectionName: String = documentChangeDetails.documentKey.collectionName
                let documentId: String = documentChangeDetails.documentKey.documentID as! String
                DDPLog.p("DDP", title: changeTypeName, params: collectionName, documentId)
                
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
