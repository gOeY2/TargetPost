//
//  Date+Extension.swift
//  FitnessSharing
//
//  Created by Krish on 8/20/22.
//

import Foundation

extension Date {
    func stripTime() -> Date {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: self)
        let date = Calendar.current.date(from: components)
        return date!
    }
}
