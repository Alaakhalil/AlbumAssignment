//
//  AlbumsModel.swift
//  AlbumAssignment
//
//  Created by Alaa Khalil on 1/7/21.
//

import Foundation

class AlbumsModel : Codable {
    var userId : Int?
    var id : Int?
    var title : String?

    enum CodingKeys: String, CodingKey {

        case userId = "userId"
        case id = "id"
        case title = "title"
    }

}
