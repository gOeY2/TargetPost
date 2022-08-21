//
//  Biometrics.swift
//  FitnessSharing
//
//  Created by Krish on 8/8/22.
//

import Foundation
import LocalAuthentication

class Biometrics {
    
    static let shared = Biometrics()
    
    enum BiometricType {
        case none
        case touch
        case face
    }
    
    func biometricType() -> BiometricType {
        let authContext = LAContext()
        let _ = authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        switch authContext.biometryType {
        case .none:
            return .none
        case .touchID:
            return .touch
        case .faceID:
            return .face
        @unknown default:
            return .none
        }
    }
    
    func biometricUnlock(completion: @escaping(Result<Account, Error>) -> Void) {
        let credentials = KeychainStorage.getCredentials()
        guard let credentials = credentials else {
            completion(.failure(BiometricError.credentialsNotSaved))
            return
        }
        let context = LAContext()
        var error: NSError?
        let canEvaluate = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        if let error = error {
            switch error.code {
            case -6:
                completion(.failure(BiometricError.deniedBiometricAccess))
            case -7:
                completion(.failure(BiometricError.noBiometricRegistered))
            default:
                completion(.failure(BiometricError.unknownError))
            }
        }
        if canEvaluate {
            if context.biometryType != .none {
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Biometrics needed to access credentials.") { success, error in
                    DispatchQueue.main.async {
                        if error != nil {
                            completion(.failure(BiometricError.unknownError))
                        } else {
                            FirebaseFunctions.shared.signIn(email: credentials["email"]!, password: credentials["password"]!) { (result: Result<Account, FirebaseFunctions.FirebaseError>) in
                                switch result {
                                case .success(let account):
                                    completion(.success(account))
                                case .failure(let error):
                                    completion(.failure(error))
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    enum BiometricError: Error, LocalizedError, Identifiable {
        
        var id: String {
            self.localizedDescription
        }
        
        case unknownError
        case deniedBiometricAccess
        case noBiometricRegistered
        case credentialsNotSaved
        
        var errorDescription: String?  {
            switch self {
            case .unknownError:
                return NSLocalizedString("An unexpected error occurred. Please try again.", comment: "")
            case .deniedBiometricAccess:
                return NSLocalizedString("Biometric sign-in has been denied permissions for this app. Please turn on Face ID for this app in Settings, then try again.", comment: "")
            case .noBiometricRegistered:
                return NSLocalizedString("No biometrics have been detected for this device. Please set up biometrics for this device and try again.", comment: "")
            case .credentialsNotSaved:
                return NSLocalizedString("No credentials are saved on this device. Would you like to save them after the next successful login?", comment: "")
            }
        }
    }
}
