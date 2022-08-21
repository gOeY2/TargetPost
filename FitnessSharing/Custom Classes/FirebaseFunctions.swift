//
//  FirebaseFunctions.swift
//  FitnessSharing
//
//  Created by Krish on 8/8/22.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import AuthenticationServices

class FirebaseFunctions {
    
    static let shared = FirebaseFunctions()
    var storeCredsNext = false
    
    func signIn(email: String, password: String, completion: @escaping((Result<Account, FirebaseError>) -> Void)) {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        if validate(email: trimmedEmail, password: trimmedPassword) {
            exists(email: trimmedEmail, provider: .email) { (result: Result<Bool, FirebaseError>) in
                switch result {
                case .success:
                    let credential = EmailAuthProvider.credential(withEmail: trimmedEmail, password: trimmedPassword)
                    self.authenticate(credential: credential) { (result: Result<String, FirebaseError>) in
                        switch result {
                        case .success(let uid):
                            self.getDocument(from: Firestore.firestore().collection("Accounts").document(uid)) { (result: Result<DocumentSnapshot, FirebaseError>) in
                                switch result {
                                case .success:
                                    let account = Account(from: uid)
                                    if self.storeCredsNext {
                                        if KeychainStorage.saveCredentials(email: email, password: password)  {
                                            completion(.success(account))
                                        }
                                    } else {
                                        completion(.success(account))
                                    }
                                case .failure(let error):
                                    completion(.failure(error))
                                }
                            }
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } else {
            completion(.failure(.noAccountFound))
        }
    }
    
    func signUp(name: String, email: String, password: String, completion: @escaping((Result<Account, FirebaseError>) -> Void)) {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        if validate(email: trimmedEmail, password: trimmedPassword) {
            exists(email: trimmedEmail, provider: .email) { (result: Result<Bool, FirebaseError>) in
                switch result {
                case .success:
                    completion(.failure(.accountExists))
                case .failure(let error):
                    if error == .noAccountFound {
                        Auth.auth().createUser(withEmail: trimmedEmail, password: trimmedPassword) { authResult, err in
                            if let error = err {
                                print(error.localizedDescription)
                                completion(.failure(FirebaseError.fromDescription(description: error.localizedDescription)))
                            }
                            if let result = authResult {
                                Firestore.firestore().collection("Accounts").document(result.user.uid).setData(["name": name, "email": trimmedEmail]) { err in
                                    if let error = err {
                                        print(error.localizedDescription)
                                        completion(.failure(FirebaseError.fromDescription(description: error.localizedDescription)))
                                    } else {
                                        let account = Account(from: result.user.uid)
                                        if self.storeCredsNext {
                                            if KeychainStorage.saveCredentials(email: email, password: password)  {
                                                completion(.success(account))
                                            }
                                        } else {
                                            completion(.success(account))
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        completion(.failure(error))
                    }
                }
            }
        }
    }
    
    private func validate(email: String, password: String) -> Bool {
        return (NSPredicate(format:"SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}").evaluate(with: email) && NSPredicate(format:"SELF MATCHES %@", "^(?=.*[A-Z])(?=.*[!@#$&*])(?=.*[0-9]).{8,}$").evaluate(with: password))
    }
    
    private func exists(email: String, provider: Provider, completion: @escaping((Result<Bool, FirebaseError>) -> Void)) {
        Auth.auth().fetchSignInMethods(forEmail: email) { prov, err in
            if let error = err {
                print(error.localizedDescription)
                completion(.failure(FirebaseError.fromDescription(description: error.localizedDescription)))
            }
            if let providers = prov, !providers.isEmpty {
                if providers.contains(self.providerString(from: provider)) {
                    completion(.success(true))
                } else {
                    completion(.failure(.wrongProvider))
                }
            } else {
                completion(.failure(.noAccountFound))
            }
        }
    }
    
    private func authenticate(credential: AuthCredential, completion: @escaping((Result<String, FirebaseError>) -> Void)) {
        Auth.auth().signIn(with: credential) { authResult, err in
            if let error = err {
                print(error.localizedDescription)
                completion(.failure(FirebaseError.fromDescription(description: error.localizedDescription)))
            }
            if let result = authResult {
                completion(.success(result.user.uid))
            }
        }
    }
    
    private func providerString(from provider: Provider) -> String {
        switch provider {
        case .email:
            return "password"
        case .google:
            return "google.com"
        case .apple:
            return "apple.com"
        }
    }
    
    enum Provider {
        case email
        case google
        case apple
    }
    
    func getDocument(from docRef: DocumentReference, completion: @escaping(((Result<DocumentSnapshot, FirebaseError>) -> Void))) {
        docRef.getDocument { docSnapshot, err in
            if let error = err {
                print(error.localizedDescription)
                completion(.failure(FirebaseError.fromDescription(description: error.localizedDescription)))
            }
            if let document = docSnapshot {
                completion(.success(document))
            } else {
                completion(.failure(.noDocumentFound))
            }
        }
    }
    func getDocument(from query: Query, completion: @escaping(((Result<[DocumentSnapshot], FirebaseError>) -> Void))) {
        query.getDocuments { querySnapshot, err in
            if let error = err {
                print(error.localizedDescription)
                completion(.failure(FirebaseError.fromDescription(description: error.localizedDescription)))
            }
            if let documents = querySnapshot?.documents, !documents.isEmpty {
                completion(.success(documents))
            } else {
                completion(.failure(.noDocumentFound))
            }
        }
    }
    
    func createDocId() -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let docId = String((0..<20).map{ _ in letters.randomElement()! })
        return docId
    }
    
    enum FirebaseError: Error, LocalizedError, Identifiable {
        var id: String {
            self.localizedDescription
        }
        
        case unknownError
        case noAccountFound
        case accountExists
        case wrongProvider
        case invalidCredentials
        case wrongCredentials
        case internetIssues
        case noDocumentFound
        case invalidPermissions
        
        var errorDescription: String?  {
            switch self {
            case .invalidCredentials:
                return NSLocalizedString("The credentials provided are not formatted correctly. Please enter an email (ex. a@b.com) and a password (8+ characters: 1 capital, 1 lowercase, 1 number, and 1 special character) in order to proceed.", comment: "")
            case .unknownError:
                return NSLocalizedString("An unexpected error occurred. Please try again.", comment: "")
            case .noAccountFound:
                return NSLocalizedString("The credentials provided are not linked to an account. Would you like to sign up instead?", comment: "")
            case .wrongProvider:
                return NSLocalizedString("The credentials provided are linked to an account with a different sign-in provider. Please use that provider to log in or use different credentials.", comment: "")
            case .internetIssues:
                return NSLocalizedString("Please make sure the network connection is secure and try again.", comment: "")
            case .noDocumentFound:
                return NSLocalizedString("There is no existing entry at the current location. Please try again.", comment: "")
            case .invalidPermissions:
                return NSLocalizedString("Your account does not have the sufficient permissions to access this. Please try again.", comment: "")
            case .accountExists:
                return NSLocalizedString("The credentials provided are linked to an account. Would you like to log in instead?", comment: "")
            case .wrongCredentials:
                return NSLocalizedString("The credentials provided are invalid. Please try different credentials.", comment: "")
            }
        }
        
        static func fromDescription(description: String) -> FirebaseError {
            switch description {
            case "Network error (such as timeout, interrupted connection or unreachable host) has occurred.":
                return .internetIssues
            case "The password is invalid or the user does not have a password.":
                return .wrongCredentials
            default:
                return .unknownError
            }
        }
    }
}
