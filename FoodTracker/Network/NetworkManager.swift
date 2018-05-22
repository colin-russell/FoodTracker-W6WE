//
//  SignupRequestController.swift
//  FoodTracker
//
//  Created by Colin on 2018-05-21.
//  Copyright © 2018 Colin Russell. All rights reserved.
//
import UIKit
import Foundation

class NetworkManager {
    
    //MARK: Properties
    var username = "colin123"
    var password = "1234"
    var httpMethod = ""
    var token = "czZ1kL3Sh6pDhfXih5HM5biN"
    let session = URLSession(configuration: URLSessionConfiguration.default)
    
//    func login() { // probably want to take in a username & password later
//
//        guard var url = URL(string: "https://cloud-tracker.herokuapp.com/login") else {return}
//        let URLParams = [
//            "username": "colin123",
//            "password": "1234",
//            ]
//        url = url.appendingQueryParameters(URLParams)
//
//        httpMethod = "POST"
//
//        var request = URLRequest(url: url)
//        request.httpMethod = httpMethod
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        let task = session.dataTask(with: URLRequest(url: url), completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
//            if (error == nil) {
//                // Success
//                let statusCode = (response as! HTTPURLResponse).statusCode
//                print("URL Session Task Succeeded: HTTP \(statusCode)")
//            }
//            else {
//                // Failure
//                print("URL Session Task Failed: %@", error!.localizedDescription);
//            }
//
//            DispatchQueue.main.async {
//                let json = try? JSONSerialization.jsonObject(with: data!, options: [])
//                print(json!)
//            }
//        })
//        task.resume()
//        session.finishTasksAndInvalidate()
//
//    }

    func saveMeal(completion: @escaping () -> Void) {
        let url = URL(string: "https://cloud-tracker.herokuapp.com/users/me/meals")!
        httpMethod = "POST"

        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.addValue("czZ1kL3Sh6pDhfXih5HM5biN", forHTTPHeaderField: "token")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if (error == nil) {
                // Success
                let statusCode = (response as! HTTPURLResponse).statusCode
                print("URL Session Task Succeeded: HTTP \(statusCode)")
            }
            else {
                // Failure
                print("URL Session Task Failed: %@", error!.localizedDescription)
               // completion(nil)
            }

            DispatchQueue.main.async {

                guard let results = try! JSONSerialization.jsonObject(with: data!, options: []) as? [[String : Any]] else {
                    print("Invalid JSON")
                    //completion(nil)
                    return
                }

                var mealArray = [Meal]()
                for i in 0..<results.count {
                    let mealJSON = results[i]
                    let meal = Meal(name: mealJSON["title"] as! String,
                                    photo: nil,
                                    rating: mealJSON["rating"] as? Int ?? 0,
                                    calories: mealJSON["calories"] as? Int ?? 0,
                                    mealDescription: mealJSON["description"] as? String ?? "")
                    mealArray.append(meal!)
                }
                //completion(mealArray)
            }
        })
        task.resume()
        session.finishTasksAndInvalidate()
    }
    
    func fetchAllMeals(completion: @escaping (_ meals: [Meal]?) -> Void) {
        let url = URL(string: "https://cloud-tracker.herokuapp.com/users/me/meals")!
        httpMethod = "GET"
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.addValue("czZ1kL3Sh6pDhfXih5HM5biN", forHTTPHeaderField: "token")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
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
                                    mealDescription: mealJSON["description"] as? String ?? "")
                    mealArray.append(meal!)
                }
                completion(mealArray)
            }
        })
        task.resume()
        session.finishTasksAndInvalidate()
    }
    
}

