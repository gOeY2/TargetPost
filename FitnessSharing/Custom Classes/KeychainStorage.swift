//
//  KeychainStorage.swift
//  FitnessSharing
//
//  Created by Krish on 6/28/22.
//

import Foundation
import SwiftKeychainWrapper

enum KeychainStorage {
    static let key = "credentials"

    static func getCredentials() -> [String: String]? {
        if let credentialsString = KeychainWrapper.standard.string(forKey: self.key) {
            let credentials = Credentials.decode(credentialsString)
            return credentials.toDict()
        } else {
            return nil
        }
    }

    static func saveCredentials(email: String, password: String) -> Bool {
        let credentials = Credentials(email: email, password: password)
        return KeychainWrapper.standard.set(credentials.encoded(), forKey: self.key)
    }

    struct Credentials: Codable {
        var email: String = ""
        var password: String = ""

        func encoded() -> String {
            let encoder = JSONEncoder()
            let credentialsData = try! encoder.encode(self)
            return String(data: credentialsData, encoding: .utf8)!
        }

        static func decode(_ credentialsString: String) -> Credentials {
            let decoder = JSONDecoder()
            let jsonData = credentialsString.data(using: .utf8)
            return try! decoder.decode(Credentials.self, from: jsonData!)
        }

        func toDict() -> [String: String] {
            return ["email": self.email, "password": self.password]
        }
    }
}
