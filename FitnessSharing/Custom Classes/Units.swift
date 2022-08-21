//
//  Units.swift
//  FitnessSharing
//
//  Created by Krish on 8/20/22.
//

import Foundation

enum Units: String, CaseIterable, Identifiable {
    case reps, sets, hours, minutes, seconds, pounds, kilograms, miles, kilometers, feet, meters
    var id: Self { self }
    
    static let strings: [Units: String] = [.reps: "Reps", .sets: "Sets", .hours: "Hours", .minutes: "Minutes", .seconds: "Seconds", .pounds: "Pounds", .kilograms: "Kilograms", .miles: "Miles", .kilometers: "Kilometers", .feet: "Feet", .meters: "Meters"]
}
