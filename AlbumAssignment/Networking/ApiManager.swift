//
//  ApiManager.swift
//  AlbumAssignment
//
//  Created by Alaa Khalil on 1/7/21.
//

import Foundation

class ApiManager: BaseAPI<ApiNetworking> {
    
   static let shared = ApiManager()
    
    //MARK:- Requestes
    func getAlbums(completion: @escaping (Result<[AlbumsModel]?, NSError>)-> Void){
        self.fetchData(target: .getAlbums, responseClass: [AlbumsModel].self) { (result) in
            completion(result)
        }
    }
    
    
}
