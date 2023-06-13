//
//  WeatherApplicationApp.swift
//  WeatherApplication
//
//  Created by Palash Roy on 6/12/23.
//

import SwiftUI
/// Entry point of the app. calls the contentview for the UI.
@main
struct WeatherApplicationApp: App {
    var body: some Scene {
        WindowGroup {
            ZStack {
                // Creating a gradient background with fullview
                Rectangle().fill(
                    LinearGradient(gradient: Gradient(colors: [.violet, .indigo]), startPoint: .top, endPoint: .bottom)
                ).edgesIgnoringSafeArea(.all)
                ContentView()
            }
        }
    }
}
