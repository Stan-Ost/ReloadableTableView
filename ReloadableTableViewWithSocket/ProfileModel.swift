//
//  ProfileModel.swift
//  TableViewWithMultipleCellTypes
//
//  Created by Stanislav Ostrovskiy on 4/25/17.
//  Copyright © 2017 Stanislav Ostrovskiy. All rights reserved.
//

import Foundation

class Profile {
    var fullName: String?
    var pictureUrl: String?
    var email: String?
    var about: String?
    var friends = [Friend]()
    var profileAttributes = [Attribute]()
    
    init?(data: [String: AnyObject]?) {
        guard let data = data, let body = data["data"] as? [String: Any] else {
            return
        }
        
        self.fullName = body["fullName"] as? String
        self.pictureUrl = body["pictureUrl"] as? String
        self.about = body["about"] as? String
        self.email = body["email"] as? String
        
        if let friends = body["friends"] as? [Any] {
            self.friends = friends.flatMap { Friend(json: $0 as? [String: Any]) }
        }
        
        if let profileAttributes = body["profileAttributes"] as? [Any] {
            self.profileAttributes = profileAttributes.flatMap { Attribute(json: $0 as? [String: Any]) }
        }
    }
}

class Friend {
    var name = ""
    var pictureUrl = ""
    
    init?(json: [String: Any]?) {
        guard let json = json else {
            return nil
        }
        self.name = json["name"] as? String ?? ""
        self.pictureUrl = json["pictureUrl"] as? String ?? ""
    }
}

extension Friend: CustomStringConvertible {
    var description: String {
        return "\(name): \(pictureUrl)"
    }
}

class Attribute {
    var key = ""
    var value = ""
    
    init?(json: [String: Any]?) {
        guard let json = json else {
            return nil
        }
        self.key = json["key"] as? String ?? ""
        self.value = json["value"] as? String ?? ""
    }
}

extension Attribute: CustomStringConvertible {
    var description: String {
        return "\(key): \(value)"
    }
}
