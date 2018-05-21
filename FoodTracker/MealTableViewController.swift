//
//  MealTableViewController.swift
//  FoodTracker
//
//  Created by Colin on 2018-05-21.
//  Copyright © 2018 Colin Russell. All rights reserved.
//

import UIKit
import os.log


class MealNetworkManager {
    
    //MARK: Properties
    var username = "colin123"
    var password = "1234"
    var httpMethod = ""
    var token = "czZ1kL3Sh6pDhfXih5HM5biN"
    
    func login() { // probably want to take in a username & password later
        //let url = URL(string: "https://cloud-tracker.herokuapp.com/login")!
        guard var url = URL(string: "https://cloud-tracker.herokuapp.com/login") else {return}
        let URLParams = [
            "username": "colin123",
            "password": "1234",
            ]
        url = url.appendingQueryParameters(URLParams)
        
        httpMethod = "POST"
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if (error == nil) {
                // Success
                let statusCode = (response as! HTTPURLResponse).statusCode
                print("URL Session Task Succeeded: HTTP \(statusCode)")
            }
            else {
                // Failure
                print("URL Session Task Failed: %@", error!.localizedDescription);
            }
            
            DispatchQueue.main.async {
                let json = try? JSONSerialization.jsonObject(with: data!, options: [])
                print(json!)
            }
        })
        task.resume()
        session.finishTasksAndInvalidate()
        
    }
    
    func fetchAllMeals(completion: @escaping (_ meals: [Meal]?) -> Void) {
        let url = URL(string: "https://cloud-tracker.herokuapp.com/users/me/meals")!
        httpMethod = "GET"
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
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
 
                guard let result = try! JSONSerialization.jsonObject(with: data!, options: []) as? [[String : Any]] else {
                    print("Invalid JSON")
                    completion(nil)
                    return
                }
                
                print("calories: \(result[0]["calories"] ?? "nil")")
                var mealArray = [Meal]()
                for i in 0..<result.count {
                    let meal = Meal(name: result[i]["title"] as! String,
                                    photo: nil,
                                    rating: result[i]["rating"] as? Int ?? 0)
                    mealArray.append(meal!)
                }
                completion(mealArray)
            }
        })
        task.resume()
        session.finishTasksAndInvalidate()
    }

}

class MealTableViewController: UITableViewController {
    
    //MARK: Properties
    var meals = [Meal]()
    let networkManager = MealNetworkManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        networkManager.fetchAllMeals { (meals) in
            
            DispatchQueue.main.async {
                if meals != nil {
                    self.meals = meals!
                }
                self.tableView.reloadData()
            }
        }
        
        // Use the edit button item provided by the table view controller.
        navigationItem.leftBarButtonItem = editButtonItem
        
//        // Load any saved meals, otherwise load sample data.
//        if let savedMeals = loadMeals() {
//            meals += savedMeals
//        }
//        else {
//            // Load the sample data.
//            loadSampleMeals()
//        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // When the app launches, check if the user's credentials are saved in UserDefaults
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch(segue.identifier ?? "") {
        case "AddItem":
            os_log("Adding a new meal.", log: OSLog.default, type: .debug)
        case "ShowDetail":
            guard let mealDetailViewController = segue.destination as? MealViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedMealCell = sender as? MealTableViewCell else {
                fatalError("Unexpected sender: \(sender ?? "nil")")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedMealCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedMeal = meals[indexPath.row]
            mealDetailViewController.meal = selectedMeal
            
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier ?? "nil")")
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meals.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90.0;//Choose your custom row height
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "MealTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? MealTableViewCell  else {
            fatalError("The dequeued cell is not an instance of MealTableViewCell.")
        }
        
        // Fetches the appropriate meal for the data source layout.
        let meal = meals[indexPath.row]
        
        cell.nameLabel.text = meal.name
        cell.photoImageView.image = meal.photo
        cell.ratingControl.rating = meal.rating
        
        return cell
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            meals.remove(at: indexPath.row)
            saveMeals()
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    //MARK: Private Methods
    
    private func loadSampleMeals() {
        let photo1 = UIImage(named: "meal1")
        let photo2 = UIImage(named: "meal2")
        let photo3 = UIImage(named: "meal3")
        
        guard let meal1 = Meal(name: "Caprese Salad", photo: photo1, rating: 5) else {
            fatalError("Unable to instantiate meal1")
        }
        
        guard let meal2 = Meal(name: "Spaghetti and Meatballs", photo: photo2, rating: 4) else {
            fatalError("Unable to instantiate meal2")
        }
        
        guard let meal3 = Meal(name: "Pizza", photo: photo3, rating: 3) else {
            fatalError("Unable to instantiate meal2")
        }
        
        meals += [meal1, meal2, meal3]
    }
    
    private func saveMeals() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(meals, toFile: Meal.ArchiveURL.path)
        if isSuccessfulSave {
            os_log("Meals successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save meals...", log: OSLog.default, type: .error)
        }
    }
    
    private func loadMeals() -> [Meal]?  {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Meal.ArchiveURL.path) as? [Meal]
    }
    
    //MARK: Actions
    
    @IBAction func unwindToMealList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? MealViewController, let meal = sourceViewController.meal {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // Update an existing meal.
                meals[selectedIndexPath.row] = meal
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            } else {
                // Add a new meal.
                let newIndexPath = IndexPath(row: meals.count, section: 0)
                
                meals.append(meal)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
            // Save the meals.
            saveMeals()
        }
    }
    
}
