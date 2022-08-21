//
//  View+Extension.swift
//  CodeHelp
//
//  Created by Krish on 8/10/22.
//

import Foundation
import SwiftUI
import UIKit

extension View {
    func alert(title: String, message: String, actions: [UIAlertAction]) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.overrideUserInterfaceStyle = .dark
        for action in actions {
            alertController.addAction(action)
        }
        
        rootController().present(alertController, animated: true)
    }
    
    func alertWithTextField(title: String, message: String, primaryTitle: String, secondaryTitle: String, primaryAction: @escaping((String) -> Void), placeholder: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.overrideUserInterfaceStyle = .dark
        alertController.addTextField { textField in
            textField.placeholder = placeholder
        }
        alertController.addAction(UIAlertAction(title: primaryTitle, style: .default, handler: { action in
            if let textField = alertController.textFields?[0] {
                if let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty {
                    primaryAction(text)
                }
            }
        }))
        alertController.addAction(UIAlertAction(title: secondaryTitle, style: .cancel))
        
        rootController().present(alertController, animated: true)
    }

    func rootController() -> UIViewController {
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .init()
        }
        
        guard let root = screen.windows.first?.rootViewController else {
            return .init()
        }
        
        return root
    }
}
