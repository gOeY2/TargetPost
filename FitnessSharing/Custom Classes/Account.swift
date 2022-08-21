//
//  Account.swift
//  FitnessSharing
//
//  Created by Krish on 8/10/22.
//

import Foundation
import FirebaseFirestore

class Account {
    
    var name = String()
    var email = String()
    var uid = String()
    var targets = [Target]()
    
    init(from uid: String) {
        self.uid = uid
        let docRef = Firestore.firestore().collection("Accounts").document(uid)
        FirebaseFunctions.shared.getDocument(from: docRef) { (result: Result<DocumentSnapshot, FirebaseFunctions.FirebaseError>) in
            switch result {
            case .success(let document):
                self.name = document.get("name") as! String
                self.email = document.get("email") as! String
                DispatchQueue.main.async {
                    if let nsTargets = document.get("targets") as? NSArray, let targetsStrings = nsTargets as? [String] {
                        for targetString in targetsStrings {
                            Target.from(docId: targetString) { (result: Result<Target, FirebaseFunctions.FirebaseError>) in
                                switch result {
                                case .success(let target):
                                    self.targets.append(target)
                                case .failure(let error):
                                    print(error.localizedDescription)
                                }
                            }
                        }
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func reloadData(completion: @escaping((Bool) -> Void)) {
        let docRef = Firestore.firestore().collection("Accounts").document(uid)
        FirebaseFunctions.shared.getDocument(from: docRef) { (result: Result<DocumentSnapshot, FirebaseFunctions.FirebaseError>) in
            switch result {
            case .success(let document):
                self.name = document.get("name") as! String
                self.email = document.get("email") as! String
                DispatchQueue.main.async {
                    if let nsTargets = document.get("targets") as? NSArray, let targetsStrings = nsTargets as? [String] {
                        for targetString in targetsStrings {
                            Target.from(docId: targetString) { (result: Result<Target, FirebaseFunctions.FirebaseError>) in
                                switch result {
                                case .success(let target):
                                    self.targets.append(target)
                                case .failure(let error):
                                    print(error.localizedDescription)
                                }
                            }
                        }
                    }
                    completion(true)
                }
            case .failure(let error):
                print(error.localizedDescription)
                completion(false)
            }
        }
    }
}
