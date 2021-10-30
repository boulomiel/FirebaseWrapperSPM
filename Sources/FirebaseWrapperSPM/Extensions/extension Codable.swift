//
//  extension Codable.swift
//  FirebaseWrapper
//
//  Created by Ruben Mimoun on 16/10/2021.
//

import Foundation


public protocol FirebaseCodable : Codable{}

extension FirebaseCodable {
    
public func toDict() -> [String : Any]{
        var dict : [String : Any] =  [:]
        let mirrored =  Mirror.init(reflecting: self)
        mirrored.children.forEach { child in
            if let label = child.label {
                
                if let firebaseCodableChild = child.value as? FirebaseCodable{
                   let childDict =  firebaseCodableChild.toDict()
                    dict[label] =  childDict
                }else if let firebaseCodableChild = child.value as? [FirebaseCodable]{
                    let childDictArr : [[String : Any]] =  firebaseCodableChild.map{$0.toDict()}
                    dict[label] =  childDictArr
                } else {
                    dict[label] = child.value
                }
            }
        }
        return dict
    }
    
}
