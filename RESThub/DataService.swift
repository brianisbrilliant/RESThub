//
//  DataService.swift
//  RESThub
//
//  Created by Brian Foster on 9/10/20.
//  Copyright © 2020 Harrison. All rights reserved.
//

import Foundation


// this will be set up as a singleton.

class DataService {
    static let shared = DataService()
    // need root URL of the API
    // https://api.github.com
    fileprivate let baseURLString = "https://api.github.com"
    
    let customSession: URLSession = {
        let customConfig = URLSessionConfiguration.default
        // let backgroundConfig
        
        customConfig.networkServiceType = .video
        customConfig.allowsCellularAccess = true
        
        return URLSession(configuration: customConfig)
    }
    
    // fucking WHAT is all of this shit? Specifically, what is @escaping?
    func fetchGists(completion: @escaping(Result<[Gist], Error>) -> Void) {
        
        //var baseURL = URL(string: baseURLString)
        //baseURL?.appendPathComponent("/somePath")
        
        //let composedURL = URL(string: "/somePath", relativeTo: baseURL)
        
        //print(baseURL!)
        //print(composedURL?.absoluteString ?? "Relative URL failed.")
        
        // something about a URL COMPONENT CLASS being a better way to do this. ^^^
        // this is easier and I like it.
        
        var componentURL = URLComponents()
        // set sceheme and host properties
        componentURL.scheme = "https"
        componentURL.host = "api.github.com"
        componentURL.path = "/gists/public"
        
    
        //print(componentURL.url!)
        // what if the URL is bad?
        guard let validURL = componentURL.url else {
            print("URL Creation failed.")
            return
        }
        
        // parse the data, look at the response, error
        URLSession.shared.dataTask(with: validURL) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                print("API Status: \(httpResponse.statusCode)")
                // error codes: 200 success, 400 client error (that's us), 500 server error.
            }
            
            // did it all work fine?
            guard let validData = data, error == nil else {
                print("API error: \(error?.localizedDescription)")
                completion(.failure(error!))
                return
            }
            
            // handle the JSON since we got it just fine.
            
            do {
                //let json = try JSONSerialization.jsonObject(with: validData, options:[])
                let gists = try JSONDecoder().decode([Gist].self, from: validData)
                //print(json)
                completion(.success(gists))
            // if there was an error with this, run the catch code block.
            } catch let serializationError {
                //print(serializationError.localizedDescription)
                completion(.failure(serializationError))
            }
            
        }.resume()      // this function doesn't start until it gets to this .resume()!
       
    }
    
    func createNewGist( : @escaping(Result<Any, Error>) -> Void) {
        
        // here we are using the helper function that we created just after this one.
        let postComponents = createURLComponents(path: "/gists")
        guard let composedURL = postComponents.url else {
            print("URL Creation failed.")
            return      // break out of the function
        }
        
        var postRequest = URLRequest(url: composedURL)
        postRequest.httpMethod = "POST"
    
        
        postRequest.setValue("Basic \(createAuthCredentials())", forHTTPHeaderField: "Authorization")
        // content type header is good to know about too.
        postRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // accpet header file
        postRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let newGist = Gist(id: nil, isPublic: true, description: "Learning REST APIs", files: ["file.txt": File(content: "All your base are belong to us.")])
        
        do {
            let gistData = try JSONEncoder().encode(newGist)
            postRequest.httpBody = gistData
        } catch {
            print("Gist encoding failed.")
        }
        
        URLSession.shared.dataTask(with: postRequest) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                print("Status code: \(httpResponse.statusCode)")
            }
            
            guard let validData = data, error == nil else {
                completion(.failure(error!))
                return
            }
            
            // serialize the data into json first
            do {
                let json = try JSONSerialization.jsonObject(with: validData, options: [])
                completion(.success(json))
            } catch  let serializationError {
                completion(.failure(serializationError))
            }
            
        }.resume()
    }
    
    // this is a small helper function to keep track of "https" and "api.github.com" so that we don't have to type it all the time.
    func createURLComponents(path: String) -> URLComponents {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.github.com"
        components.path = path
        
        return components
    }
    
    // helper function to return an encoded string
    func createAuthCredentials() -> String {
        // KEEP THIS PRIVATE
        let authString = "63ea0126449fc021ac9f7652903c88b9b98fb275"
        var authStringBase64 = ""
        
        // more security, this will be sent via URL i think
        if let authData = authString.data(using: .utf8) {
            authStringBase64 = authData.base64EncodedString()
        }
        
        return authStringBase64
    }
    
    func starUnstarGist(id: String, star: Bool, completion: @escaping (Bool) -> Void) {
        let starComponents = createURLComponents(path: "/gists/\(id)/star")
        guard let composedURL = starComponents.url else {
            print("Component composition failed.")
            return
        }
        
        var starRequest = URLRequest(url: composedURL)
        starRequest.httpMethod = star == true ? "PUT" : "DELETE"        // if star is true, say "PUT", else say "DELETE"
        
        starRequest.setValue("0", forHTTPHeaderField: "Content-Length")
        starRequest.setValue("Basic \(createAuthCredentials())", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: starRequest) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                print("Status Code: \(httpResponse.statusCode)")
                
                // could this be a ternary?
                if httpResponse.statusCode == 204 {
                    completion(true)
                } else {
                    completion(false)
                }
                
            }
        }.resume()
    }
}
