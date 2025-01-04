// 
//  See LICENSE.text for this project’s licensing information.
//
//  Mockable.swift
//
//  Created by Bilal Durnagöl on 24.02.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import Foundation
@testable import RevenueMore

protocol Mockable: AnyObject {
    var bundle: Bundle { get }
    func loadJSON<T: Decodable>(filename: String, type: T.Type, completion: (Result<T, BaseError>) -> Void)
}

extension Mockable {
    var bundle: Bundle {
        return Bundle.module
    }

    func loadJSON<T: Decodable>(filename: String, type: T.Type, completion: (Result<T, BaseError>) -> Void) {
        guard let path = bundle.url(forResource: filename, withExtension: "json") else {
            fatalError("Failed to load JSON")
        }

        do {
            let data = try Data(contentsOf: path)
            let decodedObject = try JSONDecoder().decode(BaseResponse<T>.self, from: data)
            guard let statusCode = decodedObject.meta?.code else { return }
            
            switch statusCode {
            case 200...299:
                if let safeData = decodedObject.data {
                    completion(.success(safeData))
                } else {
                    completion(.failure(.decode))
                }
            case 400..<500:
                completion(.failure(.custom(error: decodedObject.error?.userMessage)))
            default:
                completion(.failure(.unexpectedStatusCode))
            }
        } catch {
            fatalError("Failed to decode loaded JSON")
        }
    }
}
