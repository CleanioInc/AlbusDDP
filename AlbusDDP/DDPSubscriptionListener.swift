//
//  DDPSubscriptionListener.swift
//  AlbusDDP
//
//  Created by Guillaume Elloy on 10/03/2017.
//  Copyright © 2017 Cleanio Services SAS. All rights reserved.
//


protocol DDPSubscriptionListener: class {
    func onSubscriptionReady(_ ready: Bool)
}
