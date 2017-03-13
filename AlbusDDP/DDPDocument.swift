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
    
    static let kJsonId: String = "_id"
    
    var id: String?
    
    required public init?(map: Map) {
    }
    
    public func mapping(map: Map) {
        self.id <- map[DDPDocument.kJsonId]
    }
    
    
    class public func build<T: DDPDocument>(documentId: String?, documentFields: JSONFields) -> T? {
        if let newDocument = Mapper<T>().map(JSON: documentFields) {
            newDocument.id = documentId
            return newDocument
        }
        return nil
    }
    
    public func update<T:DDPDocument>(updatedFields: JSONFields?, removedFields: String?, type: T.Type) {
        if let updatedFields = updatedFields {
            self.updateFields(updatedFields: updatedFields, type: type)
        }
        if let removedFields = removedFields {
            self.removeFields(removedFields: removedFields)
        }
    }
    
    
    fileprivate func updateFields<T:DDPDocument>(updatedFields: JSONFields, type: T.Type) {
        if let updatedDocument = Mapper<T>().map(JSON: updatedFields) {
            let mirroredUpdatedDocument = Mirror(reflecting: updatedDocument)
            for field in mirroredUpdatedDocument.children {
                let label = field.label
                let value = field.value
                let mirroredValue = Mirror(reflecting: value)
                if mirroredValue.children.count > 0 && label != nil {
                    self.setValue(value, forKey: field.label!)
                }
            }
        }
    }
    
    fileprivate func removeFields(removedFields: String) {
        if let removedFieldsData = removedFields.data(using: String.Encoding.utf8, allowLossyConversion: true) {
            do {
                if let removedFieldsNames = try JSONSerialization.jsonObject(with: removedFieldsData, options: .allowFragments) as? [String] {
                    for fieldName in removedFieldsNames {
                        self.setNilValueForKey(fieldName)
                    }
                }
            } catch let error {
                print("DDP ### PARSING ERROR : \(error)")
            }
        }
    }
    
}

