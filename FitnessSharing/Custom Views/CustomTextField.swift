//
//  CustomTextField.swift
//  FitnessSharing
//
//  Created by Krish on 8/20/22.
//

import SwiftUI

struct CustomTextField: View {
    
    @Binding var text: String
    var label: String
    var isSecure: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
                .font(.system(size: 19))
                .foregroundColor(.gray)
                .fontWeight(.semibold)
            if isSecure {
                SecureField("", text: $text)
                    .autocapitalization(.none)
                    .tint(Color("Blue"))
            } else {
                TextField("", text: $text)
                    .keyboardType(label == "Email" ? .emailAddress:.default)
                    .autocapitalization(.none)
                    .tint(Color("Blue"))
            }
            Rectangle()
                .frame(maxWidth: .infinity)
                .frame(height: 2)
                .foregroundColor(.gray.opacity(0.7))
        }
    }
}
