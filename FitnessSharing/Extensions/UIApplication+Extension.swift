//
//  UIApplication+Extension.swift
//  CodeHelp
//
//  Created by Krish on 8/10/22.
//

import Foundation
import UIKit

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
