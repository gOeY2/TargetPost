//
//  LoginView.swift
//  FitnessSharing
//
//  Created by Krish on 8/10/22.
//

import SwiftUI
import UIKit
import AuthenticationServices

struct LoginView: View {
    
    @EnvironmentObject var habitat: Habitat
    @State private var name = String()
    @State private var email = String()
    @State private var password = String()
    @State private var isSecure = true
    @StateObject private var keyboardHandler = KeyboardHandler()
    @State private var isNewAccount = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                Image("loginTopImage")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .ignoresSafeArea(.all, edges: .top)
                Spacer()
            }
            VStack {
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 24) {
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Hit")
                                    .font(.system(size: 30))
                                    .bold()
                                Text("your targets")
                                    .font(.system(size: 30))
                                    .bold()
                                    .foregroundColor(Color("Blue"))
                                Text("with glory")
                                    .font(.system(size: 30))
                                    .bold()
                            }
                        }
                        
                        if isNewAccount {
                            CustomTextField(text: $name, label: "Name", isSecure: false)
                        }
                        CustomTextField(text: $email, label: "Email", isSecure: false)
                        ZStack(alignment: .trailing) {
                            CustomTextField(text: $password, label: "Password", isSecure: isSecure)
                            Button(action: {
                                isSecure.toggle()
                            }) {
                                Image(systemName: self.isSecure ? "eye.slash" : "eye")
                                    .accentColor(.gray)
                            }
                            .padding()
                        }
                        
                        VStack(alignment: .leading) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(isNewAccount ? "Already have an account?":"New to \(Bundle.main.displayName ?? "TargetPost")?")
                                        .foregroundColor(.gray)
                                    Button {
                                        isNewAccount.toggle()
                                    } label: {
                                        Text(isNewAccount  ?  "Log in":"Sign up")
                                            .bold()
                                        Image(systemName: "arrowtriangle.right.fill")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 8)
                                            .padding(.leading)
                                    }
                                    .foregroundColor(.black)
                                }
                            }
                        }
                    }
                    
                    if Biometrics.shared.biometricType() != .none {
                        Button {
                            Biometrics.shared.biometricUnlock { (result: Result<Account, Error>) in
                                switch result {
                                case .success(let account):
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                        habitat.account = account
                                    }
                                case .failure(let error):
                                    if error as? FirebaseFunctions.FirebaseError == FirebaseFunctions.FirebaseError.noAccountFound {
                                        alert(title: "No Account Found", message: error.localizedDescription, actions: [.init(title: "Yes", style: .default, handler: { _ in
                                            isNewAccount = true
                                        }), .init(title: "No", style: .cancel)])
                                    } else if error as? Biometrics.BiometricError == Biometrics.BiometricError.credentialsNotSaved {
                                        alert(title: "Enable Biometric Log In", message: "Would you like to use \(Biometrics.shared.biometricType() == .face ? "Face ID":"Touch ID") to log in with the next used credentials?", actions: [.init(title: "Yes", style: .default, handler: { _ in
                                            FirebaseFunctions.shared.storeCredsNext = true
                                        }), .init(title: "No", style: .cancel)])
                                    } else {
                                        alert(title: "Unexpected error", message: error.localizedDescription, actions: [.init(title: "Ok", style: .default)])
                                    }
                                }
                            }
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color("Teal").opacity(0.5))
                                    .frame(height: 48)
                                HStack(spacing: 5) {
                                    Image(systemName: Biometrics.shared.biometricType() == .face ? "faceid":"touchid")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                    Text("Sign in with \(Biometrics.shared.biometricType() == .face ? "Face ID":"Touch ID")")
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                    }
                    Button {
                        let email = self.email.trimmingCharacters(in: .whitespacesAndNewlines)
                        let password = self.password.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !isNewAccount {
                            FirebaseFunctions.shared.signIn(email: email, password: password) { (result: Result<Account, FirebaseFunctions.FirebaseError>) in
                                self.handleCompletion(result: result)
                            }
                        } else {
                            let name = self.name.trimmingCharacters(in: .whitespacesAndNewlines)
                            FirebaseFunctions.shared.signUp(name: name, email: email, password: password) { (result: Result<Account, FirebaseFunctions.FirebaseError>) in
                                self.handleCompletion(result: result)
                            }
                        }
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(LinearGradient(colors: [.init("Teal"), .init("Blue")], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(height: 48)
                            Text(isNewAccount ? "Sign up":"Log in")
                                .font(.title2)
                                .bold()
                                .foregroundColor(.white)
                                .padding()
                        }
                        .shadow(color: .init("Teal").opacity(0.6), radius: 10, x: 0, y: 5)
                    }
                }
                .padding(.vertical, 40)
                .padding(.horizontal)
                .background(.white)
                .cornerRadius(30)
                if keyboardHandler.keyboardHeight > 0 {
                    Spacer()
                }
            }
        }
        .ignoresSafeArea(.all, edges: .bottom)
        .onTapGesture {
            self.endEditing()
        }
        
    }
    
    private func endEditing() {
        UIApplication.shared.endEditing()
    }
    
    private func handleCompletion(result: Result<Account, FirebaseFunctions.FirebaseError>) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            switch result {
            case .success(let account):
                if KeychainStorage.getCredentials() == [:] {
                    alert(title: "Use Biometrics to Log In", message: "Would you like to use \(Biometrics.shared.biometricType() == .face ? "Face ID":"Touch ID") to log in?", actions: [.init(title: "Yes", style: .default, handler: { _ in
                        if KeychainStorage.saveCredentials(email: email, password: password) {
                            habitat.account = account
                        }
                    }), .init(title: "No", style: .cancel)])
                } else {
                    habitat.account = account
                }
            case .failure(let error):
                if error == FirebaseFunctions.FirebaseError.noAccountFound {
                    alert(title: "No Account Found", message: error.localizedDescription, actions: [.init(title: "Yes", style: .default, handler: { _ in
                        isNewAccount = true
                    }), .init(title: "No", style: .cancel)])
                } else if error == FirebaseFunctions.FirebaseError.accountExists {
                    alert(title: "Account Exists with Credentials", message: error.localizedDescription, actions: [.init(title: "Yes", style: .default, handler: { _ in
                        isNewAccount = false
                    }), .init(title: "No", style: .cancel)])
                } else {
                    alert(title: "Unexpected error", message: error.localizedDescription, actions: [.init(title: "Ok", style: .default)])
                }
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
