// 
//  See LICENSE.text for this project’s licensing information.
//
//  HTTPClient.swift
//
//  Created by Bilal Durnagöl on 24.02.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import Foundation

protocol HTTPClient: Sendable {
    @available(iOS 15.0, tvOS 13.0, macOS 12.0, *)
    func sendRequestAsync<T: Decodable>(endpoint: Endpoint, responseModel: T.Type) async -> Result<T, BaseError>
    @available(iOS 15.0, tvOS 13.0, macOS 12.0, *)
    func sendRequestWithRetryAsync<T: Decodable>(endpoint: Endpoint, responseModel: T.Type, retryCount: Int) async -> Result<T, BaseError>
    func sendRequest<T: Decodable>(endpoint: Endpoint, responseModel: T.Type, completion: @escaping @Sendable (Result<T, BaseError>) -> Void)
    var backendConfigurator: BackendConfigurator { get set }
}

extension HTTPClient {

    func sendRequest<T: Decodable>(endpoint: Endpoint, responseModel: T.Type, completion: @escaping @Sendable (Result<T, BaseError>) -> Void) {
        guard let url = URL(string: endpoint.scheme + endpoint.host + endpoint.apiVersion)?.appendingPathComponent(endpoint.path) else {
            💩("invalid url: \(endpoint.scheme + endpoint.host + endpoint.apiVersion + endpoint.path)")
            completion(.failure(.invalidURL))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.allHTTPHeaderFields = backendConfigurator.createHTTPHeaderFields()
        switch endpoint.body {
        case .requestPlain:
            break
        case .requestParameters(parameters: let parameters, encoding: let encoding):
            switch encoding {
            case .httpBody:
                request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
            case .query:
                if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false), !parameters.isEmpty {
                    urlComponents.queryItems = parameters.map { (key, value) in
                        URLQueryItem(name: key, value: value as? String)
                    }
                    request.url = urlComponents.url
                }
            }
        }
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                💩("API: Failure \(String(format: "%@ - '%@'", (request.httpMethod ?? ""), url.absoluteString))")
                completion(.failure(.custom(error: error?.localizedDescription)))
                return
            }
            guard let response = response as? HTTPURLResponse else {
                💩("API: No response \(String(format: "%@ - '%@'", (request.httpMethod ?? ""), url.absoluteString))")
                completion(.failure(.noResponse))
                return
            }
            📋("API: \(String(format: "%@ - '%@' - (%d)", (request.httpMethod ?? ""), url.absoluteString, response.statusCode))")

            guard
                let decodedResponse = try? JSONDecoder().decode(BaseResponse<T>.self, from: data!)
            else {
                💩("API: Failure decode \(String(format: "%@ - '%@'", (request.httpMethod ?? ""), url.absoluteString))")
                completion(.failure(.decode))
                return
            }
            switch response.statusCode {
            case 200...299:
                if let safeData = decodedResponse.data {
                    completion(.success(safeData))
                } else {
                    completion(.failure(.decode))
                }
            case 400..<500:
                completion(.failure(.custom(error: decodedResponse.error?.userMessage)))
            default:
                completion(.failure(.unexpectedStatusCode))
            }
        }
        task.resume()
    }

    @available(iOS 15.0, tvOS 13.0, macOS 12.0, *)
    func sendRequestAsync<T: Decodable>(
        endpoint: Endpoint,
        responseModel: T.Type
    ) async -> Result<T, BaseError> {
        var urlComponents = URLComponents()
        urlComponents.scheme = endpoint.scheme
        urlComponents.host = endpoint.host
        urlComponents.path = endpoint.path

        guard let url = urlComponents.url else {
            return .failure(.invalidURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.allHTTPHeaderFields = backendConfigurator.createHTTPHeaderFields()

        switch endpoint.body {
        case .requestPlain:
            break
        case .requestParameters(parameters: let parameters, encoding: let encoding):
            switch encoding {
            case .httpBody:
                request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
            case .query:
                var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
                urlComponents?.queryItems = parameters.map { (key, value) in
                    URLQueryItem(name: key, value: value as? String)
                }
                request.url = urlComponents?.url
            }
        }
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let response = response as? HTTPURLResponse else {
                💩("API: No response \(String(format: "%@ - '%@'", (request.httpMethod ?? ""), url.absoluteString))")
                return .failure(.noResponse)
            }

            📋("API: \(String(format: "%@ - '%@' - (%d)", (request.httpMethod ?? ""), url.absoluteString, response.statusCode))")

            switch response.statusCode {
            case 200...299:
                guard let decodedResponse = try? JSONDecoder().decode(responseModel, from: data) else {
                    return .failure(.decode)
                }
                return .success(decodedResponse)
            case 401:
                return .failure(.unauthorized)
            default:
                return .failure(.unexpectedStatusCode)
            }
        } catch {
            return .failure(.unknown)
        }
    }

    @available(iOS 15.0, tvOS 13.0, macOS 12.0, *)
    func sendRequestWithRetryAsync<T: Decodable>(
        endpoint: Endpoint,
        responseModel: T.Type,
        retryCount: Int = 3
    ) async -> Result<T, BaseError> {
        var currentRetyCount = 0

        while currentRetyCount < retryCount {
            let result = await sendRequestAsync(endpoint: endpoint, responseModel: responseModel)

            switch result {
            case .success:
                return result
            case .failure(let error):
                if case BaseError.unauthorized = error {
                    if let token = await refreshAccessToken() {
                        // change token here
                        print("token: \(token)")
                        currentRetyCount += 1
                        continue
                    } else {
                        return .failure(.retryFailed)
                    }
                } else {
                    return result
                }
            }
        }

        return .failure(.retryFailed)

    }

    @available(iOS 15.0, tvOS 13.0, macOS 10.15.0, *)
    func refreshAccessToken() async -> String? {
        return ""
    }
}
