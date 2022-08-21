//
//  Target.swift
//  FitnessSharing
//
//  Created by Krish on 8/20/22.
//

import Foundation
import FirebaseFirestore

struct Target: Hashable {
    var activity: String
    var currentValue: Double
    var target: Double
    var units: Units
    var startDate: Date
    var endDate: Date
    var lastBestDate: Date
    var docId: String
    
    static func from(docId: String, completion: @escaping((Result<Target, FirebaseFunctions.FirebaseError>) -> Void)) {
        FirebaseFunctions.shared.getDocument(from: Firestore.firestore().collection("Targets").document(docId)) { (result: Result<DocumentSnapshot, FirebaseFunctions.FirebaseError>) in
            switch result {
            case .success(let document):
                let activity = document.get("activity") as! String
                let currentValue = document.get("currentValue") as! Double
                let targetValue = document.get("target") as! Double
                let startTimestamp = document.get("startDate") as! Timestamp
                let startDate = startTimestamp.dateValue()
                let endTimestamp = document.get("endDate") as! Timestamp
                let endDate = endTimestamp.dateValue()
                let lastBestTimestamp = document.get("lastBestDate") as! Timestamp
                let lastBestDate = lastBestTimestamp.dateValue()
                let index = document.get("unitIndex") as! Int
                let target = Target(activity: activity, currentValue: currentValue, target: targetValue, units: Units.allCases[index], startDate: startDate, endDate: endDate, lastBestDate: lastBestDate, docId: docId)
                completion(.success(target))
            case .failure(let error):
                print(error.localizedDescription)
                completion(.failure(error))
            }
        }
    }
}
