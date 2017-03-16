//
//  DDPViewController.swift
//  AlbusDDP
//
//  Created by Guillaume Elloy on 13/03/2017.
//  Copyright © 2017 Cleanio Services SAS. All rights reserved.
//

import Foundation


open class DDPViewController: UIViewController {
    
    
    fileprivate var listenedCollections: [DDPCollection<DDPDocument>]!
    
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.listenedCollections = [DDPCollection<DDPDocument>]()
        DDPLog.p("DDP", header: "TEST", params: "ON LISTEN COLLECTION")
        for anyCollection in self.onListenCollections() {
            if let ddpCollection = anyCollection as? DDPCollection<DDPDocument> {
                DDPLog.p("DDP", header: "TEST", params: "COLLECTION AS DDPDOCUMENT")
                self.listenedCollections.append(ddpCollection)
            }
        }
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.onRefreshCollections()
        self.addViewControllerAsCollectionsListener()
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        self.removeViewControllerAsCollectionsListener()
        super.viewWillDisappear(animated)
    }
    
    
    //MARK: - DDPViewController INHERITANCE
    
    open func onListenCollections() -> [Any] {
        return []
    }
    
    open func onRefreshCollections() {
        
    }
    
    open func onCollectionUpdatedOnMainQueue<T:DDPDocument>(_ collection: DDPCollection<T>, documentId: String?, updateType: DDPUpdateType) {
        
    }
    
    
    //MARK: - DDPViewController HELPERS
    
    private func addViewControllerAsCollectionsListener() {
        for collection in self.listenedCollections {
            DDPLog.p("DDP", header: "TEST", params: "VC AS COLLECTION LISTENER")
            collection.addCollectionListener(self)
        }
    }
    
    private func removeViewControllerAsCollectionsListener() {
        for collection in self.listenedCollections {
            collection.removeCollectionListener(self)
        }
    }
    
    
}


extension DDPViewController: DDPCollectionListener {
    
    open func onCollection<T:DDPDocument>(_ collection: DDPCollection<T>, updatedDocument documentId: String?, withUpdateType updateType: DDPUpdateType) {
        DispatchQueue.main.async(execute: {
            self.onCollectionUpdatedOnMainQueue(collection, documentId: documentId, updateType: updateType)
        });
    }
    
}

