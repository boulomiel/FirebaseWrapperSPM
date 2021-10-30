//
//  DbWrapperErrors.swift
//  FirebaseWrapper
//
//  Created by Ruben Mimoun on 24/09/2021.
//

import Foundation

public struct FireWrapperError : LocalizedError {
    
    let title : String
    let message : String
    
    public init(title : String, message : String){
        self.title =  title
        self.message =  message
    }
    
}

enum DBWrapperErrorType {
    case nilResult, notDecodable, unserializable, selfIsNil, emptySnapShot(String), getData(String), snapshotUnavailable, noDataForKey, wrongCodable, objectNotFound, unauthorized, cancelled, unknown
    
    var error : FireWrapperError{
        switch self{
        case .wrongCodable:
            return FireWrapperError(title: "Can not be serialized", message: "The snapshot value cannot be json serialized, because the codable doesn't fit the data")
        case .nilResult:
            return FireWrapperError(title: "The snapshot value is nil", message: "Check if the path to the value exists")
        case .notDecodable:
            return FireWrapperError(title: "Can not decode this type", message: "The chosen type is not Decodable protocol typed")
        case .unserializable:
            return FireWrapperError(title: "Can not be serialized", message: "The snapshot value cannot be json serialized")
        case .selfIsNil:
            return FireWrapperError(title: "Instance of self", message: "self in closure is nil")
        case .emptySnapShot(let path):
            return FireWrapperError(title: "Empty snapshot", message: "Snapshot is empty or does not exist at  path  : \(path)")

        case .getData(let errorMessage):
            return FireWrapperError(title: "Could not get data", message: "\(errorMessage)")
        case .snapshotUnavailable:
            return FireWrapperError(title: "Snapshot doesnt exist", message: "Snapshot for this reference path is unavailable or does not exist")
        case .noDataForKey:
            return FireWrapperError(title: "Data Unavailable", message: "the value for this key is nil or doesn't exist")
        case .objectNotFound:
            return FireWrapperError(title: "Storage", message: "Object not found")
        case .unauthorized:
            return FireWrapperError(title: "Storage", message: "You don't have the permission to access this file")
        case .cancelled:
            return FireWrapperError(title: "Storage", message: "The task has been cancelled")
        case .unknown:
            return FireWrapperError(title: "Storage", message: "An unknow error has occured, maybe served related")
        }
    }
}
