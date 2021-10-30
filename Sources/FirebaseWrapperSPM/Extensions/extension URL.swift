//
//  extension URL.swift
//  FirebaseWrapper
//
//  Created by Ruben Mimoun on 29/10/2021.
//

import Foundation
import UIKit


extension URL {
    
    public static func localURLForXCAsset(name: String, withExtension : String) -> URL? {
        let fileManager = FileManager.default
        guard let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {return nil}
        let url = cacheDirectory.appendingPathComponent("\(name).\(withExtension)")
        let path = url.path
        if !fileManager.fileExists(atPath: path) {
            if let image = UIImage(named: name){
                if let data = image.pngData(){
                    fileManager.createFile(atPath: path, contents: data, attributes: nil)
                }else if let dataJpg = image.jpegData(compressionQuality: 0) {
                    fileManager.createFile(atPath: path, contents: dataJpg, attributes: nil)
                }else{
                    return nil
                }
            }else{
                return nil
            }
        }
        return url
    }
}
