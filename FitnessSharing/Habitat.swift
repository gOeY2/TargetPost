//
//  Habitat.swift
//  FitnessSharing
//
//  Created by Krish on 8/1/22.
//

import Foundation
import SwiftUI

class Habitat: ObservableObject {
    @Published var isOnboarded = false
    @Published var account: Account?
    
    func updateIsOnboarded(_ success: Bool) {
        withAnimation {
            self.isOnboarded = success
        }
    }
}
