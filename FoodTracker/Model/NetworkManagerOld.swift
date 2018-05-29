//
//  SignupRequestController.swift
//  FoodTracker
//
//  Created by Colin on 2018-05-21.
//  Copyright © 2018 Colin Russell. All rights reserved.
//

import UIKit
import Foundation

// Probably should have methods to be reused for GET, POST, etc.
class NetworkManagerOld {
    
    //MARK: Properties
    var username = "colin123"
    var password = "1234"
    var httpMethod = ""
    var token = "czZ1kL3Sh6pDhfXih5HM5biN"
    let contentType = "application/json"
    
    
    func saveMeal(meal: Meal) {
        
        let mealName = meal.name.replacingOccurrences(of: " ", with: "+")
        let mealDescription = meal.mealDescription.replacingOccurrences(of: " ", with: "+")
        let mealCalories = meal.calories
        let mealRating = meal.rating
        
        httpMethod = "POST"
        guard let url = URL(string: "https://cloud-tracker.herokuapp.com/users/me/meals?title=\(mealName)&description=\(mealDescription)&calories=\(mealCalories)") else {return}
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.addValue(token, forHTTPHeaderField: "token")
        request.addValue(contentType, forHTTPHeaderField: "Content-Type")
        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if (error == nil) {
                let statusCode = (response as! HTTPURLResponse).statusCode
                print("URL Session Task Succeeded: HTTP \(statusCode)")
            }
            else {
                print("URL Session Task Failed: %@", error!.localizedDescription)
            }
            DispatchQueue.main.async {
                guard let results = try! JSONSerialization.jsonObject(with: data!, options: []) as? [String : [String : Any]] else {
                    print("Invalid JSON")
                    return
                }
                
                let mealID = results["meal"]?["id"] ?? ""
                request.url = URL(string: "https://cloud-tracker.herokuapp.com/users/me/meals/\(mealID)/rate?rating=\(mealRating)")
                let ratingSession = URLSession(configuration: URLSessionConfiguration.default)

                let ratingTask = ratingSession.dataTask(with: request, completionHandler: { (_, ratingResponse, ratingError) in
                    if (ratingError == nil) {
                        let statusCode = (ratingResponse as! HTTPURLResponse).statusCode
                        print("URL Session ratingTask Succeeded: HTTP \(statusCode)")
                    }
                    else {
                        print("URL Session ratingTask Failed: %@", error!.localizedDescription)
                    }
                })
                ratingTask.resume()
                ratingSession.finishTasksAndInvalidate()
            }
        })
        task.resume()
        session.finishTasksAndInvalidate()
    }
   
    func deleteMeal(meal: Meal, id: Int) {
        
        httpMethod = "DELETE"
        guard let url = URL(string: "https://cloud-tracker.herokuapp.com/users/me/meals/\(id)") else {return}
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.addValue(token, forHTTPHeaderField: "token")
        request.addValue(contentType, forHTTPHeaderField: "Content-Type")
        let session2 = URLSession(configuration: URLSessionConfiguration.default)
        
        let task = session2.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if (error == nil) {
                let statusCode = (response as! HTTPURLResponse).statusCode
                print("URL Session Task Succeeded: HTTP \(statusCode)")
            }
            else {
                print("URL Session Task Failed: %@", error!.localizedDescription)
            }
        })
        task.resume()
        session2.finishTasksAndInvalidate()
    }
    
    func fetchAllMeals(completion: @escaping (_ meals: [Meal]?) -> Void) {
        let url = URL(string: "https://cloud-tracker.herokuapp.com/users/me/meals")!
        httpMethod = "GET"
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.addValue(token, forHTTPHeaderField: "token")
        request.addValue(contentType, forHTTPHeaderField: "Content-Type")
        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if (error == nil) {
                // Success
                let statusCode = (response as! HTTPURLResponse).statusCode
                print("URL Session Task Succeeded: HTTP \(statusCode)")
            }
            else {
                // Failure
                print("URL Session Task Failed: %@", error!.localizedDescription)
                completion(nil)
            }
            
            DispatchQueue.main.async {
                
                guard let results = try! JSONSerialization.jsonObject(with: data!, options: []) as? [[String : Any]] else {
                    print("Invalid JSON")
                    completion(nil)
                    return
                }
                
                var mealArray = [Meal]()
                for i in 0..<results.count {
                    let mealJSON = results[i]
                    let meal = Meal(name: mealJSON["title"] as! String,
                                    photo: nil,
                                    rating: mealJSON["rating"] as? Int ?? 0,
                                    calories: mealJSON["calories"] as? Int ?? 0,
                                    mealDescription: mealJSON["description"] as? String ?? "",
                                    id: mealJSON["id"] as? Int ?? 0)
                    mealArray.append(meal!)
                }
                completion(mealArray)
            }
        })
        task.resume()
        session.finishTasksAndInvalidate()
    }
    
    func postToImgur(completion: @escaping (_ photoUrl: String) -> Void) {
        
    }
    
}


