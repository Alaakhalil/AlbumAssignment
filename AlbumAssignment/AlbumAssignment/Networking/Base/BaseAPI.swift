//
//  BaseAPI.swift
//  AlbumAssignment
//
//  Created by Alaa Khalil on 1/7/21.
//

import Foundation
import Alamofire

class BaseAPI<T: TargetType>{
    
    func fetchData<M: Decodable>(target: T, responseClass: M.Type, completion: @escaping (Result<M?, NSError>) -> Void){
        let method = Alamofire.HTTPMethod(rawValue: target.method.rawValue)
        let headers = Alamofire.HTTPHeaders(target.headers ?? [:])
        let params = buildParams(task: target.task)
        AF.request(target.baseURL + target.path , method: method, parameters: params.0, encoding: params.1, headers: headers).responseJSON { (response) in
            guard let statusCode = response.response?.statusCode else{
                // Custom Error
                print("statusCode error")
                let error = NSError(domain: target.baseURL, code: 0, userInfo: [NSLocalizedDescriptionKey: ErrorMessage.genericError])
                completion(.failure(error))
                return
            }
            if statusCode == 200 {
                // Successful Request
                guard let jsonResponse = try? response.result.get() else{
                    print("jsonResponse error")
                    let error = NSError(domain: target.baseURL, code: 0, userInfo: [NSLocalizedDescriptionKey: ErrorMessage.genericError])
                    completion(.failure(error))
                    return
                }
                guard let theJSONData = try? JSONSerialization.data(withJSONObject: jsonResponse, options: []) else {
                    //  Custom Error With Serialise The Data
                    print("There is a Serialization error")
                    let error = NSError(domain: target.baseURL, code: 0, userInfo: [NSLocalizedDescriptionKey: ErrorMessage.genericError])
                    completion(.failure(error))
                    return
                }
                guard let responseObj = try? JSONDecoder().decode(M.self, from: theJSONData) else {
                    // Custom Error With Decoding The Data
                    print("There is a decoding error")
                    let error = NSError(domain: target.baseURL, code: 0, userInfo: [NSLocalizedDescriptionKey: ErrorMessage.genericError])
                    completion(.failure(error))
                    return
                }
                completion(.success(responseObj))
            }
            
            else{
                // Error Parsing for the error message from the BE
                let error = NSError(domain: target.baseURL, code: 0, userInfo: [NSLocalizedDescriptionKey: ErrorMessage.genericError])
                completion(.failure(error))
            }
            
            
        }
        
    }
    
    private func buildParams(task: Task) -> ([String:Any], ParameterEncoding) {
        switch task {
        case .requestPlain:
            return ([:], URLEncoding.default)
        case .requestParameters(parameters: let parameters, encoding: let encoding):
            return (parameters, encoding)
        }
    }
}

