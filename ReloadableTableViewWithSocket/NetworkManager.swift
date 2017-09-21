//
//  NetworkManager.swift
//  TableViewWithMultipleCellTypes
//
//  Created by Stanislav Ostrovskiy on 9/19/17.
//  Copyright © 2017 Stanislav Ostrovskiy. All rights reserved.
//

import FirebaseDatabase

import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    
    private var ref: DatabaseReference!
    
    private init() {
        ref = Database.database().reference()
    }
    
    func loadData(onSuccess: @escaping (Profile) -> Void) {
        ref.observe(DataEventType.value, with: { (snapshot) in
            let profileDict = snapshot.value as? [String : AnyObject] ?? [:]
            if let profile = Profile(data: profileDict) {
                onSuccess(profile)
            }
        })
    }
}
