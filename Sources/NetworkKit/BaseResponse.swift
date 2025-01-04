// 
//  See LICENSE.text for this project’s licensing information.
//
//  BaseResponse.swift
//
//  Created by Bilal Durnagöl on 15.05.2024.
//
//  Copyright © 2024 RevenueMore. All rights reserved.
//

import Foundation

// swiftlint:disable redundant_string_enum_value
internal struct BaseResponse<T: Decodable>: Decodable {
    let meta: Meta?
    let data: T?
    let error: Errors?

    enum CodingKeys: String, CodingKey {
        case meta = "meta"
        case data = "data"
        case error = "errors"
    }

    init(from decoder: any Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        meta = try values.decodeIfPresent(Meta.self, forKey: .meta)
        data = try values.decodeIfPresent(T.self, forKey: .data)
        error = try values.decodeIfPresent(Errors.self, forKey: .error)
    }

    struct Meta: Decodable {
        let status: String?
        let code: Int?
        let message: String?
        let path: String?
        let language: String?
        let version: String?
        let timestamp: Double?

        enum CodingKeys: String, CodingKey {
            case status = "status"
            case code = "code"
            case message = "message"
            case path = "path"
            case language = "language"
            case version = "version"
            case timestamp = "timestamp"
        }

        init(from decoder: any Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            self.status = try values.decodeIfPresent(String.self, forKey: .status)
            self.code = try values.decodeIfPresent(Int.self, forKey: .code)
            self.message = try values.decodeIfPresent(String.self, forKey: .message)
            self.path = try values.decodeIfPresent(String.self, forKey: .path)
            self.language = try values.decodeIfPresent(String.self, forKey: .language)
            self.version = try values.decodeIfPresent(String.self, forKey: .version)
            self.timestamp = try values.decodeIfPresent(Double.self, forKey: .timestamp)
        }
    }

    struct Errors: Decodable {
        let status: String?
        let statusCode: Int?
        let errorCode: String?
        let language: String?
        let errorMessage: String?
        let userMessage: String?
        let module: String?
        let moduleCode: String?
        let projectCode: String?

        enum CodingKeys: String, CodingKey {
            case status = "status"
            case statusCode = "status_code"
            case errorCode = "error_code"
            case language = "language"
            case errorMessage = "error_message"
            case userMessage = "user_message"
            case module = "module"
            case moduleCode = "module_code"
            case projectCode = "project_code"
        }

        init(from decoder: any Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            self.status = try values.decodeIfPresent(String.self, forKey: .status)
            self.statusCode = try values.decodeIfPresent(Int.self, forKey: .statusCode)
            self.errorCode = try values.decodeIfPresent(String.self, forKey: .errorCode)
            self.language = try values.decodeIfPresent(String.self, forKey: .language)
            self.errorMessage = try values.decodeIfPresent(String.self, forKey: .errorMessage)
            self.userMessage = try values.decodeIfPresent(String.self, forKey: .userMessage)
            self.module = try values.decodeIfPresent(String.self, forKey: .module)
            self.moduleCode = try values.decodeIfPresent(String.self, forKey: .moduleCode)
            self.projectCode = try values.decodeIfPresent(String.self, forKey: .projectCode)
        }
    }

}
// swiftlint:enable redundant_string_enum_value
