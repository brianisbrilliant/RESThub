//
//  Gist.swift
//  RESThub
//
//  Created by Brian Foster on 9/11/20.
//  Copyright © 2020 Harrison. All rights reserved.
//

import Foundation

// if we inherit from Codable, we get a lot of encoding and decoding functionality.
// specifically, we'll decode the JSON into our id variable with the JSONDecoder
struct Gist: Encodable {
    var id: String?         // the question mark makes this an optional string, part of the encoding for when we send data to github to create our own gist.
    var isPublic: Bool
    var description: String
    var files: [String: File]       // this is a dictionary - how can we tell?
    
    // coding keys help us convert "public" to "isPublic" because public is a protected keyword.
    // it also means that we need to have ALL of the variables that we want to get come from here.
    enum CodingKeys: String, CodingKey {
        case id, isPublic = "public", description, files
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(isPublic, forKey: .isPublic)
        try container.encode(description, forKey: .description)
        try container.encodeIfPresent(id, forKey: .id)      // id will not be created, that is assigned by Github
        try container.encode(files, forKey: .files)
    }
    
}

extension Gist: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(String.self, forKey: .id)
        self.isPublic = try container.decode(Bool.self, forKey: .isPublic)
        self.description = try container.decodeIfPresent(String.self, forKey: .description) ?? "No Description"     // default string if missing
            // this doesn't work here because the descriptions are just empty strings. They aren't missing.
        self.files = try container.decode([String: File].self, forKey: .files)
    }
}

// a file is required for all gists.
struct File: Codable {
    var content: String?        // optional string because we won't always get these back
}
