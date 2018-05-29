//
//  Meal.swift
//  FoodTracker
//
//  Created by Colin on 2018-05-20.
//  Copyright © 2018 Colin Russell. All rights reserved.
//

import UIKit
import os.log
import Parse

class Meal:  PFObject, NSCoding { // Meal: NSObject, NSCoding
    
    //MARK: Properties
    @NSManaged var name: String
    @NSManaged var photo: UIImage?
    @NSManaged var rating: Int
    @NSManaged var calories: Int
    @NSManaged var mealDescription: String
    @NSManaged var id: Int
    
    //MARK: Archiving Paths
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("meals")

    //MARK: Types
    
    struct PropertyKey {
        static let name = "name"
        static let photo = "photo"
        static let rating = "rating"
        static let calories = "calories"
        static let mealDescription = "mealDescription"
        static let id = "id"
    }
    
    //MARK: Initialization
    init?(name: String, photo: UIImage?, rating: Int, calories: Int, mealDescription: String, id: Int) {
        super.init()
        
        // The name must not be empty
        guard !name.isEmpty else {
            return nil
        }
        
        // The rating must be between 0 and 5 inclusively
        guard (rating >= 0) && (rating <= 5) else {
            return nil
        }
        
        self.name = name
        self.photo = photo
        self.rating = rating
        self.calories = calories
        self.mealDescription = mealDescription
        self.id = id
    }
    
    //MARK: NSCoding
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKey.name)
        aCoder.encode(photo, forKey: PropertyKey.photo)
        aCoder.encode(rating, forKey: PropertyKey.rating)
        aCoder.encode(calories, forKey: PropertyKey.calories)
        aCoder.encode(mealDescription, forKey: PropertyKey.mealDescription)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        
        // The name is required. If we cannot decode a name string, the initializer should fail.
        guard let name = aDecoder.decodeObject(forKey: PropertyKey.name) as? String else {
            os_log("Unable to decode the name for a Meal object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        // Because photo is an optional property of Meal, just use conditional cast.
        let photo = aDecoder.decodeObject(forKey: PropertyKey.photo) as? UIImage
        
        let rating = aDecoder.decodeInteger(forKey: PropertyKey.rating)
        
        let calories = aDecoder.decodeInteger(forKey: PropertyKey.calories)
        
        let mealDescription = aDecoder.decodeObject(forKey: PropertyKey.mealDescription) as? String ?? ""
        
        let id = aDecoder.decodeInteger(forKey: PropertyKey.id)
        
        // Must call designated initializer.
        self.init(name: name, photo: photo, rating: rating, calories: calories, mealDescription: mealDescription, id: id)
        
    }
    
}

extension Meal: PFSubclassing {
    
    // required
    static func parseClassName() -> String {
        return "Meal"
    }
    
}
