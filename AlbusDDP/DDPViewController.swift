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
        for anyCollection in self.onListenCollections() {
            if let ddpCollection = anyCollection as? DDPCollection<DDPDocument> {
                self.listenedCollections.append(ddpCollection)
            }
        }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(DDPViewController.applicationWillEnterForeground),
                                               name: NSNotification.Name.UIApplicationWillEnterForeground,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(DDPViewController.applicationDidEnterBackground),
                                               name: NSNotification.Name.UIApplicationDidEnterBackground,
                                               object: nil)
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.onRefreshCollections()
        self.addViewControllerAsCollectionsListener()
    }
    
    override open func viewDidDisappear(_ animated: Bool) {
        self.removeViewControllerAsCollectionsListener()
        super.viewDidDisappear(animated)
    }
    
    // MARK: Actions/Targets
    
    open func applicationWillEnterForeground() {
        self.onRefreshCollections()
    }
    
    open func applicationDidEnterBackground() {
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
        })
    }
    
}

