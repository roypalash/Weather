//
//  WeatherApplicationTests.swift
//  WeatherApplicationTests
//
//  Created by Palash Roy on 6/12/23.
//

import XCTest
import CoreLocation
@testable import WeatherApplication


final class WeatherApplicationTests: XCTestCase {
        
    /// Mock WeatherService implementation for testing
    class MockWeatherService: WeatherService {
        var fetchWeatherDataCalled = false
        var fetchImageCalled = false
        func fetchWeatherData(for location: CLLocationCoordinate2D, completion: @escaping (WeatherApplication.WeatherData?, Error?) -> Void) {
            fetchWeatherDataCalled = true
            let weatherData = readJSONFile(forName: "WeatherByLocation")
            completion(weatherData, nil)
        }
        
        func fetchWeather(for city: String, completion: @escaping (WeatherApplication.WeatherData?, Error?) -> Void) {
            fetchWeatherDataCalled = true
            completion(readJSONFile(forName: "WeatherByLocation"), nil)
        }
        
        func fetchImage(name: String, completion: @escaping (UIImage?, Error?) -> Void) {
            fetchImageCalled = true
            completion(UIImage(), nil)
        }
        
            
        func readJSONFile(forName name: String)-> WeatherData? {
            do {
                if let bundlePath = Bundle.main.path(forResource: name, ofType: "json"),
                   let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) {
                    let decodedData = try JSONDecoder().decode(WeatherData.self, from: jsonData)
                    return decodedData
                }
            } catch {
                print(error)
                return nil
            }
            return nil
        }
        
    }
        
    let mockWeatherService = MockWeatherService()
    var viewModel: WeatherViewModel?
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        viewModel = WeatherViewModel(weatherService: mockWeatherService)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        viewModel = nil
    }

    func testFetchWeather() {
        // When
        viewModel?.fetchWetherForCity(name: "London")
        // Then
        XCTAssertTrue(mockWeatherService.fetchWeatherDataCalled, "fetchWeatherData should be called")
        XCTAssertNotNil(viewModel?.weatherData, "weatherData should not be nil")
        XCTAssertEqual(viewModel?.weatherData?.main?.temp, 13.96, "Incorrect temperature value")
        XCTAssertTrue(mockWeatherService.fetchImageCalled, "fetchImage should be called")
    }

    func testLocationManagerDidFailWithError() {
            // Given
            let mockWeatherService = MockWeatherService()
            let viewModel = WeatherViewModel(weatherService: mockWeatherService)
            let expectedError = NSError(domain: "TestDomain", code: 123, userInfo: nil)
            
            // When
            viewModel.locationManager(CLLocationManager(), didFailWithError: expectedError)
            
            // Then
            XCTAssertNil(viewModel.weatherData, "weatherData should be nil")
        }
}
