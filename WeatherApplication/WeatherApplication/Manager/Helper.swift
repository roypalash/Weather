//
//  Constants.swift
//  WeatherApplication
//
//  Created by Palash Roy on 6/12/23.
//

import Foundation
import SwiftUI
/// constant strings and urls
struct urlStrings {
    static let apiKey = "931332684c9862008dea36a42bdc564b"
    static let urlForLocation = "https://api.openweathermap.org/data/2.5/weather?lat=%@&lon=%@&appid=%@&units=metric"
    static let urlForCity = "https://api.openweathermap.org/data/2.5/weather?q=%@&appid=%@&units=metric"
    static let imageURL = "https://openweathermap.org/img/wn/%@@2x.png"
}

 /// Adding custom colors
extension Color {
    static let offWhite = Color("offWhite")
    static let mordernBlack = Color("mordernBlack")
    static let indigo = Color("indigo")
    static let violet = Color("violet")
    static let darkBlue = Color("darkBlue")
}
