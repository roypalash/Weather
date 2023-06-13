//
//  WeatherViewModel.swift
//  WeatherApplication
//
//  Created by Palash Roy on 6/12/23.
//

import Foundation
import CoreLocation
import UIKit

/// ViewModel class which has the dependency on the WeatherService
/// ViewModel will fetch the data based on location using the location delegates.
/// ViewModel will fetch the data based on the city name
/// ViewModel will fetch the image based on the image name coming from the weather data

class WeatherViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    /// Published object to be received by the UI once the data is updated by the api call result
    @Published var weatherData: WeatherData?
    @Published var weatherIcon: UIImage?
    @Published var errortext: String = ""
    private let locationManager = CLLocationManager()
    private let weatherService: WeatherService
    private var lastImage: UIImage?
    private var lastImageName = ""
    
    /// Weather service is injected in  the viewmodel to run the api calls
    init(weatherService: WeatherService) {
        self.weatherService = weatherService
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    /// Calling the api for current location based on the location
    /// - Parameters:
    ///   - manager: location manager
    ///   - locations: location array with coordinates
    func fetchWeather() {
        locationManager.requestLocation()
    }
    /// fetching weather data based on the city name
    /// - Parameters:
    ///   - name: city name
    func fetchWetherForCity(name: String) {
        weatherService.fetchWeather(for: name, completion: {[weak self] weather, error in
            guard let self = self else { return}
            if error == nil {
                self.weatherData = weather
                errortext = ""
                fetchImage()
            } else {
                errortext = "Unable to obtain result"
            }
        })
    }
    /// core location delegate method
    /// - Parameters:
    ///   - manager: location manager
    ///   - locations: location array with coordinates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last?.coordinate else { return }
        
        weatherService.fetchWeatherData(for: location, completion: {[weak self] weather, error in
            guard let self = self else { return}
            if error == nil {
                self.weatherData = weather
                errortext = ""
                fetchImage()
            } else {
                errortext = "Unable to obtain result"
            }
        })
    }
    
    /// Fetch image by the image name. Image name is retrived from the weather data.
    /// it matches with the last image and cache the last image locally.
    /// if the image name is same from the last image, it send the cached image.
    func fetchImage() {
        if let imgName = weatherData?.weather?.first?.icon  {
            if lastImageName == imgName {
                weatherIcon = lastImage
            }
            weatherService.fetchImage(name: imgName) {[weak self] image, error in
                guard let self = self else { return }
                if error == nil {
                    self.lastImage = image
                    self.lastImageName = imgName
                    self.weatherIcon = lastImage
                    errortext = ""
                } else {
                    self.weatherIcon = lastImage
                }
            }
        }
    }
    /// Location delegate failure method
    /// - Parameters:
    ///   - manager: location manager
    ///   - error: Error returned by the failed scenario
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        errortext = "Unable to obtain location details"
    }
}
