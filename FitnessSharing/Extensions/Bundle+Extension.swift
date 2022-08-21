//
//  Bundle+Extension.swift
//  CodeHelp
//
//  Created by Krish on 8/10/22.
//

import Foundation

extension Bundle {
    var displayName: String? {
        return object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
    }
}
