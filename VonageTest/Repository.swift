//
//  Repository.swift
//  VonageTest
//
//  Created by Crt Gregoric on 25/05/2022.
//

import Foundation

struct Repository {
    
    private let url = "https://phone-speak-voip-dot-speak-2-dev.uc.r.appspot.com"
    
    func fetchToken(completion: @escaping (String?) -> Void) {
        guard let url = URL(string: "\(url)/vonage-user-token") else {
            completion(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, let jsonResponse = try? JSONSerialization.jsonObject(with: data) as? [String: String] else {
                completion(nil)
                return
            }

            completion(jsonResponse["token"])
        }
        task.resume()
    }
    
}
