//
//  ContentView.swift
//  WeatherApplication
//
//  Created by Palash Roy on 6/12/23.
//

import SwiftUI

struct WeatherView: View {
    @ObservedObject var viewModel: WeatherViewModel
    @State private var text: String = ""
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    // Top searchbar
                    TextField("Enter city name", text: $text)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()

                    Button(action: getWeather) {
                        Image(systemName: "magnifyingglass")
                            .padding()
                            .background(Color.mordernBlack)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        
                    }
                }
                // showing error when error text is not empty
                if !viewModel.errortext.isEmpty {
                    Text(viewModel.errortext).font(.headline).foregroundColor(.white)
                }
            }
            
            .padding()
            Spacer()
            // checking for avaoilibility of data
            if let locationData = viewModel.weatherData, let temp = locationData.main?.temp, let first = locationData.weather?.first, let desc = first.description {
                VStack{
                    // show weather image as per current weather condition
                    if let lastImage = viewModel.weatherIcon { // If Image exists
                        Image(uiImage: lastImage)
                    }
                    // Weather description
                    Text(desc)
                        .font(.headline).foregroundColor(.white)
                    // Temparature
                    Text("\(String(describing: temp))°C")
                        .font(.largeTitle)
                        .padding()
                    HStack(alignment: .center, spacing: 16) {
                        // showing supported weather data
                        if let humidity = locationData.main?.humidity, let speed = locationData.wind?.speed, let feel = locationData.main?.feelsLike {
                            VStack {
                                Text("Feels like")
                                Text("\(String(format: "%.2f", feel))°C") // Temparature upto 2 decimal places
                            }.padding()
                            VStack {
                                Text("Precipitation")
                                Text("\(humidity)%")
                            }
                            VStack {
                                Text("Wind")
                                Text("\(String(format: "%.2f", speed))kmph")
                            }.padding()
                        }
                    }
                    .padding()
                    Spacer()
                }
                Spacer()
                
            } else {
                // when data is not available
                if viewModel.errortext.isEmpty {
                    ProgressView("Fetching Weather...")
                }
            }
        }
        .onAppear {
            loadWeather()
        }
    }
    
    private func loadWeather() {
        // retriving user deafult to get the previously entered city
        text = UserDefaults.standard.string(forKey: "city") ?? ""
        getWeather()
    }
    /// Calling the the method when city name is entered
    /// - Parameters:
    ///   - manager: location manager
    ///   - locations: location array with coordinates
    private func getWeather() {
        guard !text.isEmpty else {
            viewModel.fetchWeather()
            return
        }
        viewModel.fetchWetherForCity(name: text)
        // adding city name to user defaults.
        UserDefaults.standard.set(text, forKey: "city")
    }
}

struct ContentView: View {
    var body: some View {
        WeatherView(viewModel: WeatherViewModel(weatherService: WeatherAPIService()))
    }
}

