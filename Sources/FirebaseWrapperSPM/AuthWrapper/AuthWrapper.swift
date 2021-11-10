//
//  AuthWrapper.swift
//  FirebaseWrapper
//
//  Created by Ruben Mimoun on 10/11/2021.
//

import Foundation
import Firebase
import FirebaseAuth

public class AuthWrapper {
    
    public enum AuthError : LocalizedError{
        case noResult, error(String)
        
        var title : String {
            return "Oups"
        }
        
        
        var message : String{
            switch self {
            case .noResult:
                return "No user created"
            case .error(let errorMessage):
                return errorMessage
            }
        }
    }
    
    
    private static var authListener: AuthStateDidChangeListenerHandle?
    
    public static func register(email : String, password : String, completion : @escaping(Result<User, AuthError>)->()){
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let result = result{
                completion(.success(result.user))
            }else{
                completion(.failure(.noResult))
            }
            
            if let error = error{
                completion(.failure(.error(error.localizedDescription)))
            }
        }
    }
    
    public static func login(email : String, password : String, completion : @escaping(Result<User, AuthError>)->()){
        Auth.auth().signIn(withEmail: email, link: password) { result, error in
                if let result = result{
                    completion(.success(result.user))
                }else{
                    completion(.failure(.noResult))
                }
                
                if let error = error{
                    completion(.failure(.error(error.localizedDescription)))
            }
        }
    }
    
    
    public func isConnected(completion : @escaping(Bool)->()){
        AuthWrapper.authListener = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let _ = user {
                    completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    deinit{
        if let authListener = AuthWrapper.authListener{
            Auth.auth().removeStateDidChangeListener(authListener)
        }
    }
}
