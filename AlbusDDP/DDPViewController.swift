//
//  DDPViewController.swift
//  AlbusDDP
//
//  Created by Guillaume Elloy on 13/03/2017.
//  Copyright © 2017 Cleanio Services SAS. All rights reserved.
//

import Foundation


open class DDPViewController: UIViewController {
    
    
    fileprivate var listenedCollections: [DDPCollectionProtocol]!
    
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.listenedCollections = [DDPCollectionProtocol]()
        self.listenedCollections.append(contentsOf: self.onListenCollections())
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(DDPViewController.applicationWillEnterForeground),
                                               name: NSNotification.Name.UIApplicationWillEnterForeground,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(DDPViewController.applicationDidEnterBackground),
                                               name: NSNotification.Name.UIApplicationDidEnterBackground,
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
    
    open func onListenCollections() -> [DDPCollectionProtocol] {
        return []
    }
    
    open func onRefreshCollections() {
        
    }
    
    open func onCollectionUpdatedOnMainQueue<T:DDPDocument>(_ collection: DDPCollection<T>, documentId: String?, updateType: DDPUpdateType) {
        
    }
    
    
    //MARK: - DDPViewController HELPERS
    
    open func addViewControllerAsCollectionsListener() {
        for collection in self.listenedCollections {
            collection.addCollectionListener(self)
        }
    }
    
    open func removeViewControllerAsCollectionsListener() {
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

