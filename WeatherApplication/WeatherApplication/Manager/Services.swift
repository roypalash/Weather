//
//  Services.swift
//  WeatherApplication
//
//  Created by Palash Roy on 6/12/23.
//

import Foundation
import CoreLocation
import UIKit
/// Request weatherdata from for current location
/// - Parameters:
///   - location: current location corordinates
///   - completion: The completion closure, returning weather data or an error
protocol WeatherService {
    func fetchWeatherData(for location: CLLocationCoordinate2D, completion: @escaping (WeatherData?, Error?) -> Void)
    func fetchWeather(for city: String, completion: @escaping (WeatherData?, Error?) -> Void)
    func fetchImage(name: String, completion: @escaping (UIImage?, Error?) -> Void)
}

struct WeatherAPIService: WeatherService {
    let networkManager = NetworkManager()
    /// Request weatherdata for current location
    /// - Parameters:
    ///   - location: current location corordinates
    ///   - completion: The completion closure, returning weather data or an error
    func fetchWeatherData(for location: CLLocationCoordinate2D, completion: @escaping (WeatherData?, Error?) -> Void) {
        // Make API call to fetch weather data using the location coordinates
        let urlString = String(format: urlStrings.urlForLocation, "\(location.latitude)", "\(location.longitude)", urlStrings.apiKey)
        guard let url = URL(string: urlString) else { return }
        networkManager.request(fromURL: url) { (result: Result<WeatherData, Error>) in
            switch result {
            case .success(let locationData):
                completion(locationData, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    /// Request weatherdata for city
    /// - Parameters:
    ///   - city: city name
    ///   - completion: The completion closure, returning weather data or an error
    func fetchWeather(for city: String, completion: @escaping (WeatherData?, Error?) -> Void) {
        let urlString = String(format: urlStrings.urlForCity, city, urlStrings.apiKey)
        guard let url = URL(string: urlString) else { return }
        networkManager.request(fromURL: url) { (result: Result<WeatherData, Error>) in
            switch result {
            case .success(let locationData):
                completion(locationData, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    /// Request image from weather data
    /// - Parameters:
    ///   - name: image name
    ///   - completion: The completion closure, returning image or an error
    func fetchImage(name: String, completion: @escaping (UIImage?, Error?) -> Void) {
        let urlString = String(format: urlStrings.imageURL, name)
        guard let url = URL(string: urlString) else { return }
        networkManager.request(fromURL: url, isDecodable: false) { (result: Result<Data, Error>) in
            switch result {
            case .success(let data):
                completion(UIImage(data: data), nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
}

// MARK: - Network Manager
/// This is our network class, it will handle all our requests
class NetworkManager {

    /// These are the errors this class might return
    enum ManagerErrors: Error {
        case invalidResponse
        case invalidStatusCode(Int)
    }

    /// The request method you like to use
    enum HttpMethod: String {
        case get
        case post

        var method: String { rawValue.uppercased() }
    }

    /// Request data from an endpoint
    /// - Parameters:
    ///   - url: the URL
    ///   - httpMethod: The HTTP Method to use, either get or post in this case
    ///   - isDecodable:flag to keep the isDecodable var differentae between image data as Data and decodable data
    ///   - completion: The completion closure, returning a Result of either the generic type or an error
    func request<T: Decodable>(fromURL url: URL, httpMethod: HttpMethod = .get, isDecodable: Bool = true, completion: @escaping (Result<T, Error>) -> Void) {

        // Because URLSession returns on the queue it creates for the request, we need to make sure we return on one and the same queue.
        // You can do this by either create a queue in your class (NetworkManager) which you return on, or return on the main queue.
        let completionOnMain: (Result<T, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }

        // Create the request. On the request you can define if it is a GET or POST request, add body and more.
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.method

        let urlSession = URLSession.shared.dataTask(with: request) { data, response, error in
            // First check if we got an error, if so we are not interested in the response or data.
            // Remember, and 404, 500, 501 http error code does not result in an error in URLSession, it
            // will only return an error here in case of e.g. Network timeout.
            if let error = error {
                completionOnMain(.failure(error))
                return
            }

            // Lets check the status code, we are only interested in results between 200 and 300 in statuscode. If the statuscode is anything
            // else we want to return the error with the statuscode that was returned. In this case, we do not care about the data.
            guard let urlResponse = response as? HTTPURLResponse else { return completionOnMain(.failure(ManagerErrors.invalidResponse)) }
            if !(200..<300).contains(urlResponse.statusCode) {
                return completionOnMain(.failure(ManagerErrors.invalidStatusCode(urlResponse.statusCode)))
            }

            // Now that all our prerequisites are fullfilled, we can take our data and try to translate it to our generic type of T.
            guard let data = data else { return }
            do {
                if isDecodable {
                    let decodedData = try JSONDecoder().decode(T.self, from: data)
                    completionOnMain(.success(decodedData))
                } else {
                    /// making a downgrade as the Data type is not decodable.
                    completionOnMain(.success(data as! T ))
                }
            } catch {
                debugPrint("Could not translate the data to the requested type. Reason: \(error.localizedDescription)")
                completionOnMain(.failure(error))
            }
        }
        // Start the request
        urlSession.resume()
    }
}
