//
//  StorageWrapper.swift
//  FirebaseWrapper
//
//  Created by Ruben Mimoun on 18/10/2021.
//

import Foundation
import FirebaseStorage
import FirebaseStorageUI


public class StorageWrapper : MainWrapper {
    
    let storage = Storage.storage()
    let storageRef : StorageReference!
    private var uploadTask : StorageUploadTask?
    private var downloadTask : StorageDownloadTask?
    
    public override init() {
        self.storageRef = storage.reference()
    }
    
    ///Returns a StorageReference for a specified URL string (gs://firestorebucket.io....)
    ///  - Parameter urlString : the URL  string to pull the reference from.
    ///  - Returns : StorageReference
    public func getURLReference(for urlString : String) -> StorageReference {
        return storage.reference(forURL: urlString)
    }

    ///Returns a StorageReference for a path
    ///  - Parameter path : the path to the specified store object.
    ///  - Parameter parent : true if the path is in induced from the parent of the reference, otherwise false.
    ///  - Returns : StorageReference or nil
   public func getReference(for path : String, from parent : Bool) -> StorageReference?{
        if parent{
            return storageRef.parent()?.child(path)
        }else{
            return storageRef.child(path)
        }
    }
    
    
    ///Enqueue an uploadTask
    ///  - Parameter task : task to enqueue, if nil enqueue the wrapper default upload task
    public func enqueuUploadTask(task : StorageUploadTask? = nil ){
        if  let task = task {
            task.enqueue()
        }else{
            uploadTask?.enqueue()
        }
    }
    
    ///Pause an uploadTask
    ///  - Parameter task : task to enqueue, if nil pause the wrapper default upload task
    public func pauseUploadTask(task : StorageUploadTask? = nil){
        if let task = task {
            task.pause()
        }else{
            uploadTask?.pause()
        }
    }
    
    ///Cancel an uploadTask
    ///  - Parameter task : task to enqueue, if nil cancel the wrapper default upload task
    public func cancelUploadTask(task : StorageUploadTask? = nil){
        if  let task = task {
            task.cancel()
        }else{
            uploadTask?.cancel()
        }
    }
    
    
    ///Enqueue an downloadTask
    ///  - Parameter task : task to enqueue, if nil enqueue the wrapper default download task
    public func enqueuDownloadTask(task : StorageUploadTask? = nil ){
        if  let task = task {
            task.enqueue()
        }else{
            downloadTask?.enqueue()
        }
    }
    
    ///Pause an downloadTask
    ///  - Parameter task : task to enqueue, if nil pause the wrapper default download task
    public func pauseDownloadTask(task : StorageUploadTask? = nil){
        if let task = task {
            task.pause()
        }else{
            downloadTask?.pause()
        }
    }
    
    ///Cancel an downloadTask
    ///  - Parameter task : task to enqueue, if nil cancel the wrapper default download task
    public func cancelDownloadTask(task : StorageUploadTask? = nil){
        if  let task = task {
            task.cancel()
        }else{
            downloadTask?.cancel()
        }
    }
    
    
    ///Returns the wrapper default an downloadTask
    ///- Returns : StorageDownloadTask or nil
    public func getDownloadTask() -> StorageDownloadTask?{
        return downloadTask
    }
    
    ///Returns the wrapper default an upload task
    ///- Returns : StorageUploadTask or nil
    public func getUploadTask() -> StorageUploadTask?{
        return uploadTask
    }
    
    
    ///Upload  data from a file to a StorageReference
    /// - Parameter data : the file data to upload
    /// - Parameter ref : the storage reference to upload the file to
    /// - Parameter completion : If succeed return the url of the stored reference, if not returns a FirebaseWrapperError
    public func uploadFile(from data : Data, in ref : StorageReference, with completion : @escaping((Result<URL?, FireWrapperError>) -> Void)){
         uploadTask = ref.putData(data, metadata: nil) { (metadata, error) in
          guard let metadata = metadata else {
              completion(.failure(.init(title: "StorageWrapper", message: "No metadata retrieved")))
            return
          }
            
        if let error = error{
                completion(.failure(.init(title: "StorageWrapper", message: error.localizedDescription)))
        }
          let size = metadata.size
          print("File size" , size)
          // You can also access to download URL after upload.
          ref.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    completion(.failure(.init(title: "StorageWrapper", message: "No url found")))
                  return
                }
              if let error = error {
                      completion(.failure(.init(title: "StorageWrapper", message: error.localizedDescription)))
                      return
              }else{
                  completion(.success(downloadURL))
              }

          }
        }
        
        uploadTask?.resume()
            
    }
    
    ///Upload  a local file using its local url  a StorageReference
    /// - Parameter localFile : the url to access the local file ( from Bundle or FileManager)
    /// - Parameter ref : the storage reference to upload the file to
    /// - Parameter completion : If succeed return the url of the stored reference, if not returns a FirebaseWrapperError
    public func uploadFile(from localFile : URL, in ref : StorageReference, with completion : @escaping((Result<URL?, FireWrapperError>) -> Void)){
         uploadTask = ref.putFile(from: localFile, metadata: nil) { metadata, error in
          guard let metadata = metadata else {
              completion(.failure(.init(title: "StorageWrapper", message: "No url found")))
            return
          }
          let size = metadata.size
            print("File size" , size)
            ref.downloadURL { (url, error) in
            guard let downloadURL = url else {
                completion(.failure(.init(title: "StorageWrapper", message: "No url found")))
              return
            }
                if let error = error {
                    completion(.failure(.init(title: "StorageWrapper", message: error.localizedDescription)))
                }else {
                    completion(.success(downloadURL))
                }
          }
        }
        uploadTask?.resume()
        
    }
    
    /// Returns the download url of a storage reference
    ///  - Parameter ref : the storage reference pointing tho the desired file to pull the download url from
    ///  - Parameter completion : If succeeds returns the url of the sotrage reference, otherwise return a FireWrapperError
    public func getDownloadURL(from ref : StorageReference, completion : @escaping((Result<URL, FireWrapperError>) -> Void)){
        ref.downloadURL { url, error in
            if let error = error{
                completion(.failure(.init(title: "Storage", message: "Error : \(error) \n Could not find url for ref path : \n \(ref.fullPath)")))
            }
            if let url = url{
                completion(.success(url))
            }
        }
    }
    
    /// Returns the download url of a storage reference
    ///  - Parameter ref : the storage reference pointing tho the desired file to pull the download urls from
    ///  - Parameter completion : If succeeds returns the url of the sotrage reference, otherwise return a FireWrapperError
    public func getDownloadURLs(from ref : StorageReference, completion : @escaping((Result<[URL], FireWrapperError>) -> Void)){
        ref.listAll { result, error  in
            if let error = error{
                completion(.failure(.init(title: "Storage", message: "Error : \(error) \n Could not find url for ref path : \n \(ref.fullPath)")))
                return
            }
            
            var urls = [URL]()
            result.items.forEach{[weak self]item in
                self?.getDownloadURL(from: item) { result in
                    switch result {
                    case .failure(let error) :
                        print("getDownloadUrls", "url receiving failed \(error.localizedDescription)")
                    case .success(let url):
                        urls.append(url)
                    }
                }
            }
            completion(.success(urls))
        }
    }
    

    
    // Download a file from a StorageReference to a Download folder inside the Cache Directory (Caches/Download/file)
    /// - Parameter ref : StorageReference to download the file from
    /// - Parameter fileName : The name give to the downloaded file, includes its extension (ex : pikachu.jpg)
    /// - Parameter completion : If succed returns the url of the downloaded file, otherwise returns a FireWrapperError
    public func downloadToLocal( with ref : StorageReference, fileName : String, completion: @escaping((Result<URL, FireWrapperError>)-> Void)){
        // Download to the local filesystem
        guard let cacheDirectory =  getCacheDirectory() else {
            completion(.failure(.init(title: "StorageWrapper", message: "Cache directory doesnt exist")))
            return
        }
        
        guard let url =  URL(string: "\(cacheDirectory)\(fileName)".trimmingCharacters(in: .whitespacesAndNewlines)) else{
            completion(.failure(.init(title: "StorageWrapper", message: "downloadToLocal - Local url invalid")))
            return
        }
         downloadTask = ref.write(toFile: url) { url, error in
          if let error = error {
              completion(.failure(.init(title: "Storage", message: error.localizedDescription)))
          } else {
              if let url = url{
                  completion(.success(url))
              }
          }
        }
    }
    
    ///Returns a a list of the names of the downloaded files located in Caches/Download
    /// - Returns : An array of names
    public func getDownloadedFiles() -> [String]?{
        let fileManager = FileManager.default
        guard let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {return nil}
        do {
            let filesFromBundle = try fileManager.contentsOfDirectory(atPath: "\(cacheDirectory.path)/Download")
                return filesFromBundle
            } catch {
                print(error.localizedDescription)
                return nil
            }
    }
    
    
    ///Observes the upload eventual errors, if no error occurs the uploads task resumes
    /// - Parameter errorHandler : return the FirebaseWrapperError that occured during the upload
    public func addErrorUploadObserver(errorHandler : @escaping((FireWrapperError) ->Void)){
        uploadTask?.observe(.failure) {[weak self] snapshot in
            if let error = snapshot.error as NSError? {
            switch (StorageErrorCode(rawValue: error.code)!) {
            case .objectNotFound:
                errorHandler(DBWrapperErrorType.objectNotFound.error)
                break
            case .unauthorized:
                errorHandler(DBWrapperErrorType.unauthorized.error)
              break
            case .cancelled:
                errorHandler(DBWrapperErrorType.cancelled.error)
              break
            case .unknown:
                errorHandler(DBWrapperErrorType.unknown.error)
              break
            default:
                self?.uploadTask?.resume()
              break
            }
          }
        }
    }
    
    
    
    
    /// Add an upload observer according to the wanted task status, the current status during the upload will be print.
    /// - Parameter taskStatus : StorageTaskStatus (StorageTaskStatus.progress , StorageTaskStatus.failure ...).
    public func addUploadingObserver(taskStatus : StorageTaskStatus){
        uploadTask?.observe(taskStatus, handler: { progress in
            print(progress.debugDescription)
        })
    }
    
    /// Add a progress observer, returning the current upload progress as a percentage, the result can be used to update the UI
    /// - Parameter resultHandler : return the progress as a Double in percentage.
    public func addUploadProgressObserver(resultHandler : @escaping((Double) -> Void)){
        uploadTask?.observe(.progress, handler: { snapshot in
                let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount)
                  / Double(snapshot.progress!.totalUnitCount)
                resultHandler(percentComplete)
        })
    }
    
    
    ///Observes the download eventual errors, if no error occurs the download task resumes
    /// - Parameter errorHandler : return the FirebaseWrapperError that occured during the download
    public func addDownloadObserver(errorHandler : @escaping((FireWrapperError) ->Void)){
        downloadTask?.observe(.failure) {[weak self] snapshot in
            if let error = snapshot.error as NSError? {
            switch (StorageErrorCode(rawValue: error.code)!) {
            case .objectNotFound:
                errorHandler(DBWrapperErrorType.objectNotFound.error)
                break
            case .unauthorized:
                errorHandler(DBWrapperErrorType.unauthorized.error)
              break
            case .cancelled:
                errorHandler(DBWrapperErrorType.cancelled.error)
              break
            case .unknown:
                errorHandler(DBWrapperErrorType.unknown.error)
              break
            default:
                self?.downloadTask?.resume()
              break
            }
          }
        }
    }
    
    /// Add a download observer according to the wanted task status, the current status during the download will be print.
    /// - Parameter taskStatus : StorageTaskStatus (StorageTaskStatus.progress , StorageTaskStatus.failure ...).
    public func addDownloadingObserver(taskStatus : StorageTaskStatus){
        downloadTask?.observe(taskStatus, handler: { progress in
            print(progress.debugDescription)
        })
    }
    
    
    /// Add a progress observer, returning the current download progress as a percentage, the result can be used to update the UI
    /// - Parameter resultHandler : return the progress as a Double in percentage.
    public func addDowloadProgressObserver(resultHandler : @escaping((Double) -> Void)){
        downloadTask?.observe(.progress, handler: { snapshot in
                let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount)
                  / Double(snapshot.progress!.totalUnitCount)
                resultHandler(percentComplete)
        })
    }
    
    /// Remove all observers from the default upload task meeting the StorageTaskStatus
    /// - Parameter status :  StorageTaskStatus to remove observers from,
    public func removeAllUploadObservers(for status : StorageTaskStatus){
        uploadTask?.removeAllObservers(for: status)
    }
    
    /// Remove all upload observers from the default upload task.This function is called when the StorageWrapper object is removed from memory
    public func removeAllUploadObservers(){
        uploadTask?.removeAllObservers()
    }
    
    
    /// Remove all observers from the default download task meeting the StorageTaskStatus
    /// - Parameter status :  StorageTaskStatus to remove observers from,
    public func removeAllDownloadObservers(for status : StorageTaskStatus){
        downloadTask?.removeAllObservers(for: status)
    }
    
    /// Remove all upload observers from the default download task. .
    public func removeAllDownloadObservers(){
        downloadTask?.removeAllObservers()
    }
    
    
    private func getCacheDirectory() -> String?{
        let fileManager = FileManager.default
        guard let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {return nil }
        return "\(cacheDirectory.absoluteString)Download/"
    }
    
    
    deinit{
        removeAllUploadObservers()
        removeAllDownloadObservers()
    }
    
}

extension UIImageView{
    
    public func addImage(with  ref : StorageReference, placeHolder : UIImage?){
        self.sd_setImage(with: ref, placeholderImage: placeHolder)
    }
}



