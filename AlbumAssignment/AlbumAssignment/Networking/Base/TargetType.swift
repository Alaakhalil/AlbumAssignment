//
//  TargetType.swift
//  AlbumAssignment
//
//  Created by Alaa Khalil on 1/7/21.
//

import Foundation
import Alamofire

enum HTTPMethod: String{
    case get = "GET"
    case post = "POST"
    case delete = "DELETE"
    case put = "PUT"
}

enum Task{
    // A request with no additional data.
    case requestPlain
    // A requests body set with encoded parameters.
    case requestParameters(parameters:[String: Any], encoding: ParameterEncoding)
}

protocol TargetType {
    // The target's base `URL`.
    var baseURL: String{ get }
    // The path to be appended to `baseURL` to form the full `URL`.
    var path: String{ get }
    // The HTTP method used in the request.

    var method: HTTPMethod { get }
    // The type of HTTP task to be performed.

    var task : Task { get }
    // The headers to be used in the request.

    var headers: [String: String]? { get }
}
