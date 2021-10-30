//
//  MainWrapper.swift
//  FirebaseWrapper
//
//  Created by Ruben Mimoun on 16/10/2021.
//

import Foundation
import Firebase

public class MainWrapper : ValueTypeGenerator {
    
    public init(){}

    ///  Generating type according to decodable protocol and returns the value or error
    ///
    /// - Parameter  value : result from snapshot not nil
    /// - Parameter completion : return the decoded value or error
    func generateType<T : Decodable>(with value: Any, completion: @escaping ((Result<T, FireWrapperError>) -> ())) {
        do{
            let jsonData =  try JSONSerialization.data(withJSONObject: value, options: .prettyPrinted)
            do {
                let ref =  try JSONDecoder().decode(T.self, from: jsonData)
                completion(.success(ref))
            }catch{
                completion(.failure(FireWrapperError(title: "Could not decode data", message: error.localizedDescription)))
            }
            
        }catch{
            completion(.failure(DBWrapperErrorType.unserializable.error))
        }
        
    }
    
    
    public func updateChildrenValues(in ref: DatabaseReference ,paths : String..., values : Any...){
        let dict : [String: Any] = createDict(with: paths, and: values)
       ref.updateChildValues(dict)
    }
    
    

    
    func createDict(with strings : [String],and values : [Any], currentDict : [String:Any] = [:]) -> [String:Any] {
        guard strings.count > 0 else {
            return currentDict
        }

        var dict = !currentDict.isEmpty ? currentDict : [:]
        if let copy1 = strings.first, let values1 = values.first{
            dict[copy1] = values1
           return createDict(with: Array(strings.dropFirst()), and: Array(values.dropFirst()), currentDict: dict)
        }
        return currentDict
    }
    
    func snapshotToDict(snapshot : DataSnapshot) -> [String : Any?]{
        let dict : [String:Any?] = [:]
        let snapChilden = snapshot.children.map{$0 as! DataSnapshot}
        return updateDict(snapshots: snapChilden, currentdict: dict)
    }
    
    func valueForKey(key : String, snapShots : DataSnapshot)->Any?{
        let snaps = self.snapshotToDict(snapshot: snapShots)
        return getValueForKey(key: key, dict: snaps as [String : Any])
    }
    
    private func updateDict(snapshots : [DataSnapshot], currentdict : [String : Any?]) -> [String : Any?]{
        guard snapshots.count > 0 else {
            return currentdict
        }
        var snapshotCopy =  snapshots
        let snap = snapshotCopy.removeFirst()
        var dict  = currentdict
        dict[snap.key] =  snap.value
        return updateDict(snapshots: snapshotCopy, currentdict: dict)
    }
    
    private func getValueForKey(key : String, dict : [String : Any] ) -> Any?{
        guard dict.count > 0 else{
            return nil
        }
        let max =  dict.count
        let dictKeys =  dict.keys.map{"\($0)"}
        let leftDictKeys   =  dictKeys[0..<max/2]
        let rightDictKeys =  dictKeys[max/2..<max]

        guard leftDictKeys.count > 0 else {
            return nil
        }
        
        if leftDictKeys[0] == key{
            return dict[key]
        }

        var trimmed =  dict.dropFirst()
        
        if rightDictKeys[ max - 1 ] == key{
            return dict[key]
        }
        
        trimmed = trimmed.dropLast()
        
        return getValueForKey(key: key, dict: Dictionary(trimmed))
    }
    
}
