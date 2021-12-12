//
//  FirestoreWrapper.swift
//  FirebaseWrapper
//
//  Created by Ruben Mimoun on 16/10/2021.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreUI


public class FirestoreWrapper  : MainWrapper {
    
    public let db = Firestore.firestore()
    var listeners = [String:ListenerRegistration]()
    
    ///Returns a Query of specified documents equal to a value from a collection.
    ///  - Parameter collectionName : The collection documents to compare are store at.
    ///  - Parameter key : The key value be checked
    ///  - Parameter value : The comparaison value
    public func getQueryEqualTo(in collectionName  : String , for key : String , value : Any) -> Query{
        return db.collection(collectionName).whereField(key, isEqualTo: value)
    }
    
    ///Returns a Query of specified documents greater than or equal to a value from a collection.
    ///  - Parameter collectionName : The collection documents to compare are store at.
    ///  - Parameter key : The key value be checked
    ///  - Parameter value : The comparaison value
    public func getQueryGreaterThanOrEqual (in collectionName  : String, with documentId :String?,  for key : String , value : Any) -> Query{
        return db.collection(collectionName).whereField(key, isGreaterThanOrEqualTo: value)
    }
    
    ///Returns a Query of specified documents  greater than a value from a collection.
    ///  - Parameter collectionName : The collection documents to compare are store at.
    ///  - Parameter key : The key value be checked
    ///  - Parameter value : The comparaison value
    public func getQueryIsGreaterThan(in collectionName  : String , for key : String , value : Any) -> Query{
        return db.collection(collectionName).whereField(key, isGreaterThan: value)
    }
    
    ///Returns a Query of specified documents smaller than a value from a collection.
    ///  - Parameter collectionName : The collection documents to compare are store at.
    ///  - Parameter key : The key value be checked
    ///  - Parameter value : The comparaison value
    public func getQueryIsLessThan(in collectionName  : String , for key : String , value : Any) -> Query{
        return db.collection(collectionName).whereField(key, isLessThan: value)
    }
    
    ///Returns a Query of specified documents smaller than or equal to a value from a collection.
    ///  - Parameter collectionName : The collection documents to compare are store at.
    ///  - Parameter key : The key value be checked
    ///  - Parameter value : The comparaison value
    public func getQueryIsLessThanOrEqual(in collectionName  : String , for key : String , value : Any) -> Query{
         db.collection(collectionName).whereField(key, isLessThanOrEqualTo: value)
    }
    
    ///Returns a Query of specified documents where an array contains a value from a collection.
    ///  - Parameter collectionName : The collection documents to compare are store at.
    ///  - Parameter key : The key value be checked
    ///  - Parameter value : The comparaison value
    public func getQueryForArr(in collectionName  : String , for key : String , value : Any) -> Query{
         db.collection(collectionName).whereField(key, arrayContains: value)
    }
    
    
    
    /// Add data to a specified collection . The document it will be generated automatically .  ''data" must be of type type FirebaseDecodable
    ///
    ///  - Parameter collectionName : DatabaseReference we intend to listen to
    ///  - Parameter data : Data change event
    ///  - Parameter completion : return nor error or an the id of the document lately added
    public func addData<T : FirebaseCodable>(collectionName : String, data : T, completion : @escaping( (Result<String, FireWrapperError>) -> Void)){
        var ref : DocumentReference? = nil
        ref = db.collection(collectionName).addDocument(data: data.toDict()) { err in
            if let err = err {
                completion(.failure(FireWrapperError(title: "FireStoreError", message: err.localizedDescription)))
            } else {
                if let documentId = ref?.documentID{
                    completion(.success(documentId))
                }

            }
        }
        
    }
    
    /// Add data to a specified collection, the document id is up to the developer . ''data" must be of type type FirebaseDecodable
    ///
    ///  - Parameter collectionName : DatabaseReference we intend to listen to
    ///  - Parameter data : Data change event
    public func addDocumentWitId<T : FirebaseCodable>(collectionName : String, data : T,documentId : String){
        db.collection(collectionName).document(documentId).setData(data.toDict())
    }
    
    /// Update  data to a specified collection, for the current document id. If the object to update is nested the document id parameter can be filled with the the document path name in the database . ''data" must be of type type FirebaseDecodable
    ///
    ///  - Parameter collection : DatabaseReference we intend to listen to
    ///  - Parameter data : Data change event
    ///  - Parameter completion : return nor error or an the id of the document lately added
    public func updateData(for documentId : String, in collection : String, data : [String : Any],  completion : @escaping( (Result<String, FireWrapperError>) -> Void)){
        let ref = db.collection(collection).document(documentId)
        var updateData = data        
        ref.updateData(updateData) { err in
            if let err = err {
                completion(.failure(FireWrapperError(title: "FireStoreError", message: err.localizedDescription)))
            } else {
                completion(.success(ref.documentID))
            }
        }
    }
    
    
    ///Find an array stored in collection through a reference, and update/merge its value
    ///  - Parameter collectionName : The collection documents to compare are store at.
    ///  - Parameter documentId : The document id inside the collection
    ///  - Parameter arrName : the key name of the array of the specified document
    ///  - Parameter value : The value to be merged / added.
    public func updateNestedArray(at collectionName : String , for documentId : String, at arrName : String , with  value: [Any]){
        let ref =  db.collection(collectionName).document(documentId)
            ref.updateData([
                arrName: FieldValue.arrayUnion(value)
            ])
    }
    
    ///Remove  a value from an  array stored in collection through a reference.
    ///  - Parameter collectionName : The collection documents to compare are store at.
    ///  - Parameter documentId : The document id inside the collection
    ///  - Parameter arrName : the key name of the array of the specified document
    ///  - Parameter value : The value to be removed.
    public func removeFromNestedArray(at collectionName : String , for documentId : String, at arrName : String , with  value: [Any]){
        let ref =  db.collection(collectionName).document(documentId)
        ref.updateData([
            arrName: FieldValue.arrayRemove(value)
        ])
    }
    
    
    ///Runs a transaction, it can change multiple values at once according to the chosen key. The transaction will failed if the client is offline or the key to be updated does not exist.
    ///  - Parameter collectionName : The collection documents to compare are store at.
    ///  - Parameter documentId : The document id inside the collection
    ///  - Parameter key : the key name of the value to be added or modified.
    ///  - Parameter type : The value type to be added  or modified.
    ///  - Parameter data : Data to be inserted at the chosen key.
    ///  - Parameter completion : Returns true if succeed , FireWrapperError on failure.
    public func readAndUpdate<T>(at collectionName : String , for documentId : String, for key : String, as type : T ,with  data: [String:Any],
                               completion : @escaping( (Result<Bool, FireWrapperError>) -> Void)){
        
        let sfReference = db.collection(collectionName).document(documentId)

        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let sfDocument: DocumentSnapshot
            do {
                try sfDocument = transaction.getDocument(sfReference)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                completion(.failure(.init(title: "Read and Update", message: "runTransaction Error - \(fetchError.localizedDescription)")))
                return nil
            }

            guard let _ = sfDocument.data()?[key] as? T.Type else {
                let firestoreError = FireWrapperError(title : "FireStoreError",message:  "Unable to retrieve \(key) from snapshot \(sfDocument)")
                completion(.failure(firestoreError))
                return nil
            }

            transaction.updateData(data, forDocument: sfReference)
            return nil
        }) { (object, error) in
            if let error = error {
                let firestoreError = FireWrapperError(title: "FireStoreError", message: error.localizedDescription)
                completion(.failure(firestoreError))
            } else {
                completion(.success(true))
            }
        }
    }
    
    ///Delete a document from  collection, according to its name and a specified document id.
    ///  - Parameter collectionName : The collection documents to compare are store at.
    ///  - Parameter documentId : The document id inside the collection
    public func deleteDocuments(at collectionName : String , for documentId : String){
        db.collection(collectionName).document(documentId).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
            }
        }
    }
    
    /// Removes a key of a document from a collection.
    ///  - Parameter collectionName : The collection documents to compare are store at.
    ///  - Parameter documentId : The document id inside the collection.
    ///  - Parameter key : The key to be removed
    public func deleteDocuments(at collectionName : String , for documentId : String, where key : String){
        db.collection(collectionName).document(documentId).updateData([
            key: FieldValue.delete(),
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
    }
    
    /// Retrieves the updated data from a collection as a FirebaseCodable ( inherits from Codable ) for a specified document id, it doesn't listen to changes. If called offline the data retrieved can be the latest cached one or will fail.
    ///  - Parameter collectionName : The collection documents to compare are store at.
    ///  - Parameter documentId : The document id inside the collection.
    ///  - Parameter to : FirebaseCodable type to use to infer the data as a type.
    ///  - Parameter completion : Returns the infered value or a FireWrapperError
    public func retrieveOnce<T : FirebaseCodable>(from collectionName : String, where documentId : String , decode to : T.Type  ,completion : @escaping( (Result<T, FireWrapperError>) -> Void)){
        let docRef = db.collection(collectionName).document(documentId)

        docRef.getDocument { (document, error) in
            if let document = document, document.exists , let data = document.data() {
                self.generateType(with: data, completion: completion)
            } else {
                completion(.failure(DBWrapperErrorType.noDataForKey.error))
            }
        }
    }
    
    
    func retrieveDocumentFromRef<T : FirebaseCodable>(_ decode : T.Type,dbRef : CollectionReference,completion : @escaping((Result<[T?], FireWrapperError>) -> Void)){
        dbRef.getDocuments() { (querySnapshot, err) in
               if let err = err {
                   completion(.failure(.init(title: "FireStoreError", message: err.localizedDescription)))
               } else {
                   if let documents =  querySnapshot?.documents{
                       let results = documents.map {self.generateType(with: $0.data() , as: T.self)}
                       completion(.success(results))
               }
           }
       }
    }
    
    /// Retrieves the updated data from a collection as a Dictionnary<String,Any> for a specified document id, it doesn't listen to changes. If called offline the data retrieved can be the latest cached one or will fail.
    ///  - Parameter collectionName : The collection documents to compare are store at.
    ///  - Parameter documentId : The document id inside the collection.
    ///  - Parameter completion : Returns the infered value or a FireWrapperError
    public func retrieveOnce(from collectionName : String, where documentId : String ,completion : @escaping( (Result<[String:Any], FireWrapperError>) -> Void)){
        let docRef = db.collection(collectionName).document(documentId)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists , let data = document.data() {
                completion(.success(data))
            } else {
                completion(.failure(DBWrapperErrorType.noDataForKey.error))
            }
        }
    }
    
    /// Retrieves the updated data from a collection as a FirebaseCodable ( inherits from Codable ) for a specified document id, it doesn't listen to changes. If called offline the data retrieved can be the latest cached one or will fail. indicates whether the results should be fetched from the cache only (`Source.cache`), the server only (`Source.server`), or to attempt the server and fall back to the cache (`Source.default`).
    ///  - Parameter collectionName : The collection documents to compare are store at.
    ///  - Parameter documentId : The document id inside the collection.
    ///  - Parameter to : FirebaseCodable type to use to infer the data as a type.
    ///  - Parameter source : FirestoreSource to retrieve the data from (.server , .default, .cache)
    ///  - Parameter completion : Returns the infered value or a FireWrapperError
    public func retrieveFromSourceOnce<T : Decodable>(from collectionName : String, where documentId : String , and source : FirestoreSource, decode to : T.Type  ,completion : @escaping( (Result<T, FireWrapperError>) -> Void)){
        let docRef = db.collection(collectionName).document(documentId)

        docRef.getDocument(source: source) { (document, error) in
            if let document = document, document.exists , let data = document.data() {
                self.generateType(with: data, completion: completion)
            } else {
                completion(.failure(DBWrapperErrorType.noDataForKey.error))
            }
        }
    }
    
    /// Retrieves the updated data from a collection as a Dictionnary<String,Any> for a specified document id, it doesn't listen to changes. If called offline the data retrieved can be the latest cached one or will fail. indicates whether the results should be fetched from the cache only (`Source.cache`), the server only (`Source.server`), or to attempt the server and fall back to the cache (`Source.default`).
    ///  - Parameter collectionName : The collection documents to compare are store at.
    ///  - Parameter documentId : The document id inside the collection.
    ///  - Parameter source : FirestoreSource to retrieve the data from (.server , .default, .cache)
    ///  - Parameter completion : Returns Dictionnary<String, Any> or a FireWrapperError
    public func retrieveFromSourceOnce(from collectionName : String, where documentId : String , and source : FirestoreSource ,completion : @escaping( (Result<[String:Any], FireWrapperError>) -> Void)){
        let docRef = db.collection(collectionName).document(documentId)
        docRef.getDocument(source: source) { (document, error) in
            if let document = document, document.exists , let data = document.data() {
                completion(.success(data))
            } else {
                completion(.failure(DBWrapperErrorType.noDataForKey.error))
            }
        }
    }
    
    
    
    /// Retrieves  all the data from a collection according to a specified Query ( getQueryEqualTo , getQueryGreaterThanOrEqual etc... ) as FirebaseCodable (inherits from Codable)
    ///  - Parameter query : The query to filter the result of the data retrieving.
    ///  - Parameter to : The type to be inferred.
    ///  - Parameter completion : Returns the infered value or a FireWrapperError
    public func retrieveMultipleOnce<T : FirebaseCodable>(from query : Query, decode to : T.Type  ,completion : @escaping( (Result<[T?], FireWrapperError>) -> Void)){
         query
            .getDocuments() {[weak self] (querySnapshot, err) in
                if let err = err {
                    completion(.failure(.init(title: "FireStoreError", message: err.localizedDescription)))
                } else {
                    if let documents =  querySnapshot?.documents{
                        let results = documents.map {self?.generateType(with: $0.data() , as: T.self)}
                        completion(.success(results))
                }
            }
        }
    }
    
    
    /// Retrieves  all the data from a collection according to a specified Query ( getQueryEqualTo , getQueryGreaterThanOrEqual etc... ) as an Array of Dictionnary<String,Any>.
    ///  - Parameter query : The query to filter the result of the data retrieving.
    ///  - Parameter completion : Returns the infered value or a FireWrapperError
    public func retrieveMultipleOnce(from query : Query ,completion : @escaping( (Result<[[String:Any]], FireWrapperError>) -> Void)){
         query
            .getDocuments() {(querySnapshot, err) in
                if let err = err {
                    completion(.failure(.init(title: "FireStoreError", message: err.localizedDescription)))
                } else {
                    if let documents =  querySnapshot?.documents{
                        let result = documents.map({$0.data()})
                         completion(.success(result))
                }
            }
        }
    }
    
    
    /// Retrieves  all the data from a collection as a FirebaseCodable (inherits from Codable)
    ///  - Parameter collectionName : The collection documents to compare are store at.
    ///  - Parameter to : The type to inferred to.
    ///  - Parameter completion : Returns the infered value or a FireWrapperError
    public func retrieveAllOnce<T : FirebaseCodable>(from collectionName : String , decode to : T.Type  ,completion : @escaping( (Result<[T?], FireWrapperError>) -> Void)){
        let docRef = db.collection(collectionName)
         docRef.getDocuments() { (querySnapshot, err) in
                if let err = err {
                    completion(.failure(.init(title: "FireStoreError", message: err.localizedDescription)))
                } else {
                    if let documents =  querySnapshot?.documents{
                        let results = documents.map {self.generateType(with: $0.data() , as: T.self)}
                        completion(.success(results))
                }
            }
        }
    }
    /// Listen and Retrieves  all the data from a collection as a FirebaseCodable (inherits from Codable) for a document Id.  Create and Stored a ListenerRegistration objec using the documentId as a key, it can be retrieved or removed using the methods : getListener(name: String), removeListener(name: String)
    ///  - Parameter collectionName : The collection documents to compare are store at.
    ///  - Parameter to : The type to inferred to.
    ///  - Parameter completion : Returns the infered value or a FireWrapperError
    public func listenTo<T : FirebaseCodable>(from collectionName : String, where documentId : String ,includeMetaDataChange : Bool, decode to : T.Type  ,completion : @escaping( (Result<T, FireWrapperError>) -> Void)){
        let docRef = db.collection(collectionName).document(documentId)

        let listener = docRef.addSnapshotListener(includeMetadataChanges:  includeMetaDataChange) { documentSnapshot, error in
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                let source = document.metadata.hasPendingWrites ? "Local" : "Server"
                print("\(source) data: \(document.data() ?? [:])")
                if let data = document.data(){
                    self.generateType(with: data , completion: completion)
                }else{
                    completion(.failure(DBWrapperErrorType.emptySnapShot(documentId).error))
                }
            }
        listeners[documentId] = listener
    }
    
    
    /// Listen and Retrieves  all the data from a collection as aDictionnnary<String,Any> for a document Id. Create and Stored a ListenerRegistration object, using the documentId as a key, it can be retrieved or removed using the methods : getListener(name: String), removeListener(name: String)
    ///  - Parameter collectionName : The collection documents to compare are store at.
    ///  - Parameter to : The type to inferred to.
    ///  - Parameter completion : Returns the infered value or a FireWrapperError
    public func listenTo(from collectionName : String, where documentId : String ,includeMetaDataChange : Bool ,completion : @escaping( (Result<[String:Any], FireWrapperError>) -> Void)){
        
        let docRef = db.collection(collectionName).document(documentId)
        let listener = docRef.addSnapshotListener(includeMetadataChanges:  includeMetaDataChange) { documentSnapshot, error in
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                let source = document.metadata.hasPendingWrites ? "Local" : "Server"
                print("\(source) data: \(document.data() ?? [:])")
                if let data = document.data(){
                    completion(.success(data))
                }else{
                    completion(.failure(DBWrapperErrorType.emptySnapShot(documentId).error))
                }
            }
        listeners[documentId] = listener
    }
    
    
    /// Listen and Retrieves  all the data from a collection and infer the data to a FirebaseCodable. Create and Stored a ListenerRegistration object, using the listenerName (make sure it's unique) as a key, it can be retrieved or removed using the methods : getListener(name: String), removeListener(name: String)
    ///  - Parameter collectionName : The collection documents to compare are store at.
    ///  - Parameter to : The type to inferred to.
    ///  - Parameter completion : Returns the infered value or a FireWrapperError
    public func listenToAll<T : FirebaseCodable>(from collectionName : String, decode to : T.Type, listenerName : String  ,completion : @escaping((Result<[T?], FireWrapperError>) -> Void)){
        let listener = db.collection(collectionName)
            .addSnapshotListener() { (querySnapshot, err) in
                if let err = err {
                    completion(.failure(.init(title: "FireStoreError", message: err.localizedDescription)))
                } else {
                    if let documents =  querySnapshot?.documents{
                        let results = documents.map {self.generateType(with: $0.data() , as: T.self)}
                        completion(.success(results))
                }
            }
        }
        
        listeners[listenerName] = listener
    }
    
    
    
    /// Listen and Retrieves  all the data from a collection and infer the data to an Array of Dictionnary<String,Any>. Create and Stored a ListenerRegistration object, using the listenerName (make sure it's unique) as a key, it can be retrieved or removed using the methods : getListener(name: String), removeListener(name: String)
    ///  - Parameter collectionName : The collection documents to compare are store at.
    ///  - Parameter to : The type to inferred to.
    ///  - Parameter completion : Returns the infered value or a FireWrapperError
    public func listenToAll(from collectionName : String, listenerName : String  ,completion : @escaping((Result<[[String:Any]], FireWrapperError>) -> Void)){
        let listener = db.collection(collectionName)
            .addSnapshotListener() { (querySnapshot, err) in
                if let err = err {
                    completion(.failure(.init(title: "FireStoreError", message: err.localizedDescription)))
                } else {
                    if let documents =  querySnapshot?.documents{
                        let results = documents.map {$0.data()}
                        completion(.success(results))
                }
            }
        }
        
        listeners[listenerName] = listener
    }
    
    /// Listen and Retrieves  all the data using a Query and infer the data to FirebaseCodable. Create and Stored a ListenerRegistration object, using the listenerName (make sure it's unique) as a key, it can be retrieved or removed using the methods : getListener(name: String), removeListener(name: String)
    ///  - Parameter query : The query to filter the listened data with.
    ///  - Parameter to : The type to inferred to.
    ///  - Parameter completion : Returns the infered value or a FireWrapperError
    public func listenToQuery<T : FirebaseCodable>(from query : Query, decode to : T.Type, listenerName : String  ,completion : @escaping((Result<[T?], FireWrapperError>) -> Void)){
         let listener = query
            .addSnapshotListener() { (querySnapshot, err) in
                if let err = err {
                    completion(.failure(.init(title: "FireStoreError", message: err.localizedDescription)))
                } else {
                    if let documents =  querySnapshot?.documents{
                        let results = documents.map {self.generateType(with: $0.data() , as: T.self)}
                        completion(.success(results))
                }
            }
        }
        
        listeners[listenerName] = listener
    }
    
    
    /// Listen and Retrieves  all the data using a Query and infer the data to FirebaseCodable. Create and Stored a ListenerRegistration object, using the listenerName (make sure it's unique) as a key, it can be retrieved or removed using the methods : getListener(name: String), removeListener(name: String)
    ///  - Parameter query : The query to filter the listened data with.
    ///  - Parameter to : The type to inferred to.
    ///  - Parameter completion : Returns the infered value or a FireWrapperError
    public func listenToQuery(from query : Query,  listenerName : String  ,completion : @escaping((Result<[[String:Any]], FireWrapperError>) -> Void)){
         let listener = query
            .addSnapshotListener() { (querySnapshot, err) in
                if let err = err {
                    completion(.failure(.init(title: "FireStoreError", message: err.localizedDescription)))
                } else {
                    if let documents =  querySnapshot?.documents{
                        let results = documents.map {$0.data()}
                        completion(.success(results))
                }
            }
        }
        
        listeners[listenerName] = listener
    }
    

    /// Listen to changes induced to data through a Query, returns a Dictionnary holding values for events (ex : ["Added \(listenerName)" : [String:Any]]). Create and Stored a ListenerRegistration object, using the listenerName (make sure it's unique) as a key, it can be retrieved or removed using the methods : getListener(name: String), removeListener(name: String)
    ///  - Parameter query : The query to filter the listened data with.
    ///  - Parameter completion : Returns the infered value or a FireWrapperError
    public func listenToChangeOf(from query : Query, listenerName : String ,completion : @escaping( (Result<[String : Any], FireWrapperError>) -> Void)){
        var changeDict : [String : Any] = [:]
        let listener =  query
            .addSnapshotListener() { (querySnapshot, err) in
                if let err = err {
                    completion(.failure(.init(title: "FireStoreError", message: err.localizedDescription)))
                } else {
                    
                    if let snapShot = querySnapshot{
                        snapShot.documentChanges.forEach { diff in
                            if (diff.type == .added) {
                                changeDict["Added \(listenerName)"] =  diff.document.data()
                            }
                            if (diff.type == .modified) {
                                changeDict["Modified \(listenerName)"] =  diff.document.data()

                            }
                            if (diff.type == .removed) {
                                changeDict["Removed \(listenerName)"] =  diff.document.data()
                            }
                        }
                        completion(.success(changeDict))
                }
            }
        }
        
        listeners[listenerName] = listener
    }
    
    /// Listen to changes induced to data in a collection for a specified documentId, returns a Dictionnary holding values for events (ex : ["Added \(listenerName)" : [String:Any]]). Create and Stored a ListenerRegistration object, using the listenerName (make sure it's unique) as a key, it can be retrieved or removed using the methods : getListener(name: String), removeListener(name: String)
    ///  - Parameter query : The query to filter the listened data with.
    ///  - Parameter documentId : the document id from the collection to listen to change events.
    ///  - Parameter completion : Returns the infered value or a FireWrapperError
    public func listenToChangeOf(from collectionName : String, documentId : String ,completion : @escaping( (Result<[String : Any], FireWrapperError>) -> Void)){
        var changeDict : [String : Any] = [:]
        let listener =  db.collection(collectionName)
            .addSnapshotListener() { (querySnapshot, err) in
                if let err = err {
                    completion(.failure(.init(title: "FireStoreError", message: err.localizedDescription)))
                } else {
                    
                    if let snapShot = querySnapshot{
                        snapShot.documentChanges.forEach { diff in
                            if (diff.type == .added) {
                                changeDict["Added \(collectionName)"] =  diff.document.data()
                            }
                            if (diff.type == .modified) {
                                changeDict["Modified \(collectionName)"] =  diff.document.data()

                            }
                            if (diff.type == .removed) {
                                changeDict["Removed \(collectionName)"] =  diff.document.data()
                            }
                        }
                        completion(.success(changeDict))
                }
            }
        }
        
        listeners[collectionName] = listener
    }
    
    
    /// Return a ListenerRegistration from stored listeners, return nil if the key name is wrong or the listener doesn't exist.
    /// - Parameter name : the key  the listener has been stored with
    public func getListener(name : String) -> ListenerRegistration? {
        return listeners[name]
    }
    
    /// Remove a ListenerRegistration from stored listeners.
    /// - Parameter name : the key  the listener has been stored with
    public func removeListener(name : String){
        if listeners.contains(where: { key, value in
            key == name
        }){
            listeners[name]?.remove()
        }else{
            print("Remove Listeners" , "No such listener added")
        }
    }
    
    /// Remove each and every stored listeners. this function is called when FirestoreWrapper is removed from memory.
    public func removeAllListener(){
        listeners.removeAll()
    }
    
    deinit{
        removeAllListener()
    }
}







