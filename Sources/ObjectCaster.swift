//
//  ObjectCaster.swift
//  Mapper
//
//  Created by John Coates on 4/10/17.
//

import Foundation

class ObjectCaster {
    class func cast(from value: Any) -> NSObject? {
        if let dictionaryValue = value as? [String: Any] {
            return self.cast(fromDictionary: dictionaryValue)
        } else if let arrayValue = value as? [Any] {
            return self.cast(fromArray: arrayValue)
        } else if let stringValue = value as? String {
            return NSString.init(string: stringValue)
        } else if let dataValue = value as? Data {
            return NSData.init(data: dataValue)
        }
        else {
            let type = type(of: value)
            print("Couldn't cast from type: \(type)")
            return nil
        }
    }

    class func cast(fromArray from: [Any]) -> NSArray {
        var objects = [AnyObject]()
        
        for value in from {
            if let properValue = self.cast(from: value) {
                objects.append(properValue)
            } else {
                let type = type(of: value)
                print("Couldn't cast array object with value type: \(type)")
            }
        }
        
        
        let valueBuffer = UnsafeMutablePointer<AnyObject>.allocate(capacity: objects.count)
        valueBuffer.initialize(from: objects)
        
        let finalArray = NSArray.init(objects: valueBuffer, count: objects.count)
        
        valueBuffer.deinitialize(count: objects.count)
        valueBuffer.deallocate(capacity: objects.count)
        
        return finalArray
    }
    
    #if os(Linux)
    typealias DictionaryKeyType = NSObject
    #else
    typealias DictionaryKeyType = NSCopying
    #endif
    
    class func cast(fromDictionary from: [String: Any]) -> NSDictionary {
        var objects = [AnyObject]()
        var keys = [DictionaryKeyType]()
        for (key, value) in from {
            if let properValue = self.cast(from: value) {
                objects.append(properValue)
            } else {
                let type = type(of: value)
                print("Couldn't cast dictionary key \(key) with value type: \(type)")
                continue
            }
            
            let nsKey = NSString.init(string: key)
            keys.append(nsKey)
        }
        
        let keyBuffer = UnsafeMutablePointer<DictionaryKeyType>.allocate(capacity: keys.count)
        keyBuffer.initialize(from: keys)
        
        let valueBuffer = UnsafeMutablePointer<AnyObject>.allocate(capacity: objects.count)
        valueBuffer.initialize(from: objects)
        
        for object in objects {
            let valueType = type(of: object)
//            print("type of object in objects array: \(valueType)")
        }
        
        let finalDictionary = NSDictionary.init(objects: valueBuffer, forKeys: keyBuffer, count: keys.count)
        
        keyBuffer.deinitialize(count: keys.count)
        valueBuffer.deinitialize(count: objects.count)
        keyBuffer.deallocate(capacity: keys.count)
        valueBuffer.deallocate(capacity: objects.count)
        
        for (key, value) in finalDictionary {
            let valueType = type(of: value)
//            print("finalDictionary field \(key) is type: \(valueType)")
        }
        
        return finalDictionary
    }
    
}
