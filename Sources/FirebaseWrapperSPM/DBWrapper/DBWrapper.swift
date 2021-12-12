//
//  DBWrapper.swift
//  FirebaseWrapper
//
//  Created by Ruben Mimoun on 24/09/2021.
//


protocol ValueTypeGenerator {
    
    func generateType<T : FirebaseCodable>(with value : Any, completion : @escaping((Result<T, FireWrapperError>) ->()))
}

extension ValueTypeGenerator {
    
    func generateType<T : FirebaseCodable>(with value : Any, as type : T.Type) -> T?{
        do{
            print("GENERATE",value)
            let jsonData =  try JSONSerialization.data(withJSONObject: value, options: .prettyPrinted)
            do {
                let ref =  try JSONDecoder().decode(T.self, from: jsonData)
                return ref
            }catch{
                print(DBWrapperErrorType.wrongCodable.error)
                return nil
            }
            
        }catch{
            print(DBWrapperErrorType.unserializable.error)
            return nil
        }
        
    }
}

import Foundation
import Firebase
import UIKit

public class DBWrapper : MainWrapper{
    
    ///
    ///  Generating type according to decodable protocol and returns the value or error
    ///
    /// - Parameter  value : result from snapshot not nil
    /// - Parameter completion : return the decoded value or error
//    func generateType<T : Decodable>(with value: Any, completion: @escaping ((Result<T, DBWrapperError>) -> ())) {
//        print("VALUE " , value)
//        do{
//            let jsonData =  try JSONSerialization.data(withJSONObject: value, options: .prettyPrinted)
//            do {
//                let ref =  try JSONDecoder().decode(T.self, from: jsonData)
//                completion(.success(ref))
//            }catch{
//                completion(.failure(DBWrapperError(title: "Could not decode data", message: error.localizedDescription)))
//            }
//            
//        }catch{
//            completion(.failure(DBWrapperErrorType.unserializable.error))
//        }
//        
//    }
        
    public var ref : DatabaseReference {
        get{Database.database().reference()}
    }
    
    
    /// write value at path in the database
    ///  - Parameter path : The path in the reference to update the object at
    ///  - Parameter value : Any can of value to use to update the data ( [String : Any] recommended)
    /// example :
    /// # write(at "Users/"\(userId)"/friends" , ["name" : "Paul", "age" :  35])
    public func write(at path : String, value : Any){
        ref.child(path).setValue(value)
    }
    
    /// Returns a DatabaseReference
    ///  - Returns  : DatabaseReference from which we can add a child path
    public func getRef() -> DatabaseReference{
        return ref
    }
    
    ///observe data at chosen database reference and returns a decoded result if the value type is Decodable and not nil
    ///
    ///  - Parameter ref : DatabaseReference we intend to listen to
    ///  - Parameter eventType : Data change event
    ///  - Parameter valueType : FirebaseCodable type to transform the data into
    ///  - Parameter decodedValue : return decodable or return error
    public func observe<T : FirebaseCodable>(for ref : DatabaseReference, eventType : DataEventType,valueType : T.Type? = nil ,
        decodedValue : @escaping ((Result<T,FireWrapperError>) ->())){
        ref.observe(eventType) {[weak self] snapshot  in
            guard let self = self  else {
                decodedValue(.failure(DBWrapperErrorType.selfIsNil.error))
                return}
            let dict = self.snapshotToDict(snapshot: snapshot)
            self.generateType(with: dict, completion: decodedValue)
        }
    }
    
    
    ///observe data at chosen database reference and returns a [String:Any?] result.
    ///
    ///  - Parameter ref : DatabaseReference we intend to listen to
    ///  - Parameter eventType : Data change event
    ///  - Parameter completion : return decodable or return error
    ///  
    public func observe(for ref : DatabaseReference, eventType : DataEventType,
                        completion : @escaping ((Result<[String : Any?],FireWrapperError>) ->())){
        ref.observe(eventType) {[weak self] snapshot  in
            guard let self = self else {
                completion(.failure(DBWrapperErrorType.selfIsNil.error))
                return
            }
            
            guard snapshot.exists() else{
                completion(.failure(DBWrapperErrorType.snapshotUnavailable.error))
                return
            }
            let dict = self.snapshotToDict(snapshot: snapshot)
            completion(.success(dict))
        }
    }
    
    
    ///get  only once at a specific database reference
    ///
    /// - Parameter ref : DatabaseReference we intend to listen to
    /// - Parameter result : return Any or return error
    
    public func getData(for ref: DatabaseReference, result : @escaping(Result<[String : Any?], FireWrapperError>) -> Void){
        ref.getData { [weak self ]   error, snapshot in
            guard  let self =  self else {
                result(.failure(DBWrapperErrorType.selfIsNil.error))
                return
            }
            if let error = error{
                result(.failure(DBWrapperErrorType.getData(error.localizedDescription).error))
            }
            
            guard  snapshot.exists() else {
                result(.failure(DBWrapperErrorType.snapshotUnavailable.error))
                return
            }
            
            let dict = self.snapshotToDict(snapshot: snapshot)
            result(.success(dict))
        }
        
    }
    
    
    ///get  only once at a specific database reference
    ///
    /// - Parameter ref : DatabaseReference we intend to listen to
    /// - Parameter result : return Any or return error
    
    public func getData<T : FirebaseCodable>(for ref: DatabaseReference,decode: T.Type, result : @escaping(Result<[T?], FireWrapperError>) -> Void){
        ref.getData { [weak self ]   error, snapshot in
            guard  let self =  self else {
                result(.failure(DBWrapperErrorType.selfIsNil.error))
                return
            }
            if let error = error{
                result(.failure(DBWrapperErrorType.getData(error.localizedDescription).error))
            }
            
            guard  snapshot.exists() else {
                result(.failure(DBWrapperErrorType.snapshotUnavailable.error))
                return
            }
            
            let dict = self.snapshotToDict(snapshot: snapshot)
            let fData =  dict.map{self.generateType(with: $0.value, as: T.self)}
            result(.success(fData))
        }
        
    }
    
    
    ///get data  once at a specific database reference for a snapshot collection, for a specific key
    ///
    ///  - Parameter ref : DatabaseReference we intend to pull the data from
    ///  - Parameter key : The key of the value we're searching for
    ///  - Parameter result : return Any or return error
    public func getData(for key : String , in ref : DatabaseReference, result : @escaping(Result<Any,FireWrapperError>) ->Void){
        ref.getData{[weak self] error, snapshot in
            guard  let self =  self else {
                result(.failure(DBWrapperErrorType.selfIsNil.error))
                return
            }
            if let error = error{
                result(.failure(DBWrapperErrorType.getData(error.localizedDescription).error))
            }
            
            guard  snapshot.exists() else {
                result(.failure(DBWrapperErrorType.snapshotUnavailable.error))
                return
            }
            
            guard let data = self.valueForKey(key: key, snapShots: snapshot) else{
                result(.failure(DBWrapperErrorType.noDataForKey.error))
                return
            }
            
            result(.success(data))
        }
    }
    
    
    
    
    ///observe data once for a chosen event
    /// - Parameter ref : DatabaseReference we intend to pull the data from, if nil it will use the reference to the root of the database
    /// - Parameter event : DataEventType we intend to listen to
    /// - Parameter completion : when no error return the snapshot as a []
    ///
    public func getDataOnceForEvent( for ref :DatabaseReference? =  nil , event : DataEventType, completion : @escaping((Result<[String : Any?], FireWrapperError>) ->Void)){
        let currentRef =  ref != nil ? ref : self.ref
        currentRef?.observeSingleEvent(of: event, with: {[weak self] snapshot in
            guard let self = self  else{
                completion(.failure(DBWrapperErrorType.selfIsNil.error))
            return}
            
            guard snapshot.exists() else {
                completion(.failure(DBWrapperErrorType.snapshotUnavailable.error))
                return
            }
            
            let snapShotDict = self.snapshotToDict(snapshot: snapshot)
            completion(.success(snapShotDict))
        }, withCancel: { error in
            completion(.failure(DBWrapperErrorType.getData(error.localizedDescription).error))
        })
    }
    
    ///observe data once for a chosen event
    /// - Parameter ref : DatabaseReference we intend to pull the data from, if nil it will use the reference to the root of the database
    /// - Parameter event : DataEventType we intend to listen to
    /// - Parameter to : Decobable form to turn the snapshot into
    /// - Parameter completion : when no error return the snapshot as a []
    ///
    public func getDataOnceForEvent<T:Decodable>( for ref :DatabaseReference? =  nil , event : DataEventType, decode To : T.Type, completion : @escaping((Result<T, FireWrapperError>) ->Void)){
        let currentRef =  ref != nil ? ref : self.ref
        currentRef?.observeSingleEvent(of: event, with: {[weak self] snapshot in
            guard let self = self  else{
                completion(.failure(DBWrapperErrorType.selfIsNil.error))
            return}
            
            guard snapshot.exists() else {
                completion(.failure(DBWrapperErrorType.snapshotUnavailable.error))
                return
            }
            
            let dict = self.snapshotToDict(snapshot: snapshot)
            self.generateType(with: dict, completion: completion)
        }, withCancel: { error in
            completion(.failure(DBWrapperErrorType.getData(error.localizedDescription).error))
        })
    }
    
    

    
}



extension Dictionary {

    init(_ slice: Slice<Dictionary>) {
        self = [:]

        for (key, value) in slice {
            self[key] = value
        }
    }

}

extension Array{
    
    init(_ slice : Slice<Array>){
        self = []
        self = createArrFromSlice(slice: slice, arr: [])
    }
    
    func  createArrFromSlice( slice : Slice<Array>, arr: [Element] )-> [Element] {
        guard slice.count > 0 else{
            return arr
        }
        
        var copy =  slice
        let first = copy.removeFirst()
        var copyArr = arr
        copyArr.append(first)
        
        return createArrFromSlice(slice: copy, arr: copyArr)
    }
}


