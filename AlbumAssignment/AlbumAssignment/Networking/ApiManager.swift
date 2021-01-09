//
//  ApiManager.swift
//  AlbumAssignment
//
//  Created by Alaa Khalil on 1/7/21.
//

import Foundation
import Alamofire

class ApiManager {
 
    static let shared = ApiManager()
    
    func getAlbums(completion: @escaping (_ response:  [AlbumsModel], _ error: String?) -> Void)-> Void{
        AF.request(BASE_URL+ALBUMS_PATH, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 199..<300).responseDecodable { (response: DataResponse<[AlbumsModel], AFError>) in
            switch response.result{
            case .success(let response):
                
                completion(response, nil)
            case .failure(let error):
                print("There is an error with fetch Albums \(error.localizedDescription)")
                
            }
        }
    }
    func getAllPhotos(completion: @escaping (_ response: [PhotosModel], _ error: String?) -> Void)-> Void{
           AF.request( BASE_URL+PHOTOS_PATH, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 199..<300).responseDecodable { (response: DataResponse<[PhotosModel], AFError>) in
               switch response.result{
               case .success(let response):
                   completion(response, nil)
               case .failure(let error):
                   print("There is an error with get Photos \(error.localizedDescription)")
                   
               }
           }
       }
    
    func getPhotosOfAlbum(albumId: Int, completion: @escaping (_ response: [PhotosModel], _ error: String?) -> Void)-> Void{
        AF.request( "\(BASE_URL)\(ALBUMS_PATH)/\(albumId)/\(PHOTOS_PATH)", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 199..<300).responseDecodable { (response: DataResponse<[PhotosModel], AFError>) in
               switch response.result{
               case .success(let response):
                
                   completion(response, nil)
               case .failure(let error):
                   print("There is an error with get Photos \(error.localizedDescription)")
                   
               }
           }
       }
    
    
}
    
    
    
extension JSONDecoder {
      func decodeResponse<T: Decodable>(from response: AFDataResponse<Any>) -> AFResult<T> {
        guard response.error == nil else {
          print(response.error!)
          return .failure(response.error!)
        }

        guard let responseData = response.data else {
          print("didn't get any data from API")
            return .failure(response.error!)
        }

        do {
            let item = try decode(T.self, from: responseData)
          return .success(item)
        } catch {
          print("error trying to decode response")
          print(error)
            return .failure(error as! AFError)
        }
      }
    }
    

