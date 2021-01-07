//
//  ApiNetworking.swift
//  AlbumAssignment
//
//  Created by Alaa Khalil on 1/7/21.
//

import Foundation

enum ApiNetworking{
    case getAlbums
    case getPhotosOfAlb
}
extension ApiNetworking: TargetType{
    var baseURL: String {
        switch self{
        
        case .getAlbums:
            return BASE_URL
        
        case .getPhotosOfAlb:
            return BASE_URL
        }
    }
    
    var path: String {
        switch self {
        case .getAlbums:
            return ALBUMS_PATH
        case .getPhotosOfAlb:
            return PHOTOS_PATH
        }
    }
    
    var method: HTTPMethod {
        switch self {
        default:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        default:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        return [:]
    }
    
    
}
