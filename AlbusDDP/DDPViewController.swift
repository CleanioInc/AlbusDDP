//
//  DDPViewController.swift
//  AlbusDDP
//
//  Created by Guillaume Elloy on 13/03/2017.
//  Copyright © 2017 Cleanio Services SAS. All rights reserved.
//

import Foundation


class DDPViewController: UIViewController {
    
    
    fileprivate var listenedCollections: [DDPCollection<DDPDocument>]!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.listenedCollections = [DDPCollection<DDPDocument>]()
        if let collections = self.onListenCollections() {
            self.listenedCollections.append(contentsOf: collections)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.addViewControllerAsCollectionsListener()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.removeViewControllerAsCollectionsListener()
        super.viewWillDisappear(animated)
    }
    
    
    //MARK: - DDPViewController INHERITANCE
    
    func onListenCollections() -> [DDPCollection<DDPDocument>]? {
        return nil
    }
    
    func onRefreshCollections() {
        
    }
    
    func onCollectionUpdatedOnMainQueue<T:DDPDocument>(_ collection: DDPCollection<T>, documentId: String?, updateType: DDPUpdateType) {
        
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
    
    func onCollection<T:DDPDocument>(_ collection: DDPCollection<T>, updatedDocument documentId: String?, withUpdateType updateType: DDPUpdateType) {
        DispatchQueue.main.async(execute: {
            self.onCollectionUpdatedOnMainQueue(collection, documentId: documentId, updateType: updateType)
        });
    }
    
}

