//
//  DDPDocument.swift
//  AlbusDDP
//
//  Created by Guillaume Elloy on 09/03/2017.
//  Copyright © 2017 Cleanio Services SAS. All rights reserved.
//

import Foundation
import ObjectMapper

open class DDPDocument: NSObject, Mappable {
    
    open static let kJsonId: String = "_id"
    
    open var id: String?
    
    required public init?(map: Map) {
    }
    
    open func mapping(map: Map) {
        self.id <- map[DDPDocument.kJsonId]
    }
    
    
    open class func build<T: DDPDocument>(documentId: String?, documentFields: JSONFields) -> T? {
        if let newDocument = Mapper<T>().map(JSON: documentFields) {
            newDocument.id = documentId
            return newDocument
        }
        return nil
    }
    
    open func update(updatedFields: JSONFields?) {
        if let updatedFields = updatedFields {
            let map = Map(mappingType: MappingType.fromJSON, JSON: updatedFields, toObject: true)
            self.mapping(map: map)
        }
    }
    
    
    
}

