//
//  NetworkManger.swift
//  FoodTracker
//
//  Created by Colin on 2018-05-28.
//  Copyright © 2018 Colin Russell. All rights reserved.
//

import Foundation
import Parse

class NetworkManager {
    
    private func configureParse() {
        let configuration = ParseClientConfiguration {
            $0.applicationId = "myAppId123"
            $0.clientKey = "myMasterKey123"
            $0.server = "https://may2018bbb.herokuapp.com/parse"
        }
        Parse.initialize(with: configuration)
    }
    
    func upload(meal: Meal) {
        
    }
    
    func fetchAllMeals() {
        
    }
}
