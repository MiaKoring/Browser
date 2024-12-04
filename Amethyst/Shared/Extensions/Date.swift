//
//  Date.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 04.12.24.
//
import Foundation

extension Date {
    func toString(with format: String) -> String {
        let weekdays = ["Saturday", "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
        let months = ["Januray", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
        let components = Calendar.current.dateComponents(in: .autoupdatingCurrent, from: self)
        return "\(weekdays[(components.weekday ?? 0) ]), \(components.day ?? 1). \(months[(components.month ?? 1) - 1])"
    }
}
