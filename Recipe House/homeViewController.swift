//
//  homeViewController.swift
//  Recipe House
//
//  Created by Ajay Vandra on 2/26/20.
//  Copyright © 2020 Ajay Vandra. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import PINRemoteImage

class homeViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate{
  
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var itemArray = [HomeRecipe]()
    var filterArray = [HomeRecipe]()
    var count : Int = 0
    var num = 0
    var fav : String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        print(authtoken)
        print(email)
        searchBar.delegate = self
        if Connection.isConnectedToInternet(){
        homeRecipeApi(page: num)
        }
        tableview.register(UINib(nibName: "RecipeTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! RecipeTableViewCell
        cell.recipeNameLabel.text = itemArray[indexPath.row].recipeName
        cell.RecipeTypeLabel.text = itemArray[indexPath.row].type
        cell.levelLabel.text = itemArray[indexPath.row].level
        cell.descriptionLabel.text = itemArray[indexPath.row].description
        cell.timeLabel.text = "\(itemArray[indexPath.row].time) minutes"
        cell.peopleLabel.text = "\(itemArray[indexPath.row].people) people"
        cell.count.text = itemArray[indexPath.row].count
        print(itemArray[indexPath.row].recipeID)
        fav = cell.count.text!
        print(fav)
        if fav == "0"{
            cell.favoriteButtonLabel.setImage(UIImage(named: "greyHeart"), for: .reserved)
            fav = "1"
        }else if fav == "1"{
            cell.favoriteButtonLabel.setImage(UIImage(named: "redHeart"), for: .reserved)
            favoriteApi(id: Int(itemArray[indexPath.row].recipeID)!)
            print("1")
        }
        cell.recipeImageView.pin_updateWithProgress = true
        cell.recipeImageView.pin_setImage(from: URL(string: "\(itemArray[indexPath.row].recipeImage)"))
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 330
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //print(indexPath.row)
      //  print(itemArray.count)
        if indexPath.row == itemArray.count - 1{
       print("call")
            print(indexPath.row)
                   print(itemArray.count)
            num += 10
            homeRecipeApi(page: num)
         //   tableView.reloadData()
        }
    }
    private func setUpSearchbar(){
        
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterArray = itemArray.filter({ (recipe) -> Bool in
            guard let text = searchBar.text else {return false }
            return recipe.recipeName.contains(text)
        })
        tableview.reloadData()
    }
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
         
    }
    
    func homeRecipeApi(page : Int){
              let url = URL(string: "http://192.168.2.221:3000/recipe/getrecipes?count=0")
              var request = URLRequest(url: url!)
              request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
              request.addValue(authtoken, forHTTPHeaderField: "user_authtoken")
              request.httpMethod = "GET"
              
//           let parameters: [String: Any] = ["count":page]
//              request.httpBody = parameters.percentEncoded()
              
              let task = URLSession.shared.dataTask(with: request) { data, response, error in
                  guard let data = data,
                      let response = response as? HTTPURLResponse,
                      error == nil else {
                      print("error", error ?? "Unknown error")
                      return
                  }

                  guard (200 ... 299) ~= response.statusCode else {
                      print("statusCode should be 2xx, but is \(response.statusCode)")
                      print("response = \(response)")
                      return
                  }
                  let json = try! JSON(data: data)
                  let responseString = String(data: data, encoding: .utf8)
                  print(json)
                  print(responseString!)
                
                self.count = json.count
                print(self.count)
                let a = json[0]["type_id"].stringValue
                print(a)
               
                  if responseString != nil{
                      DispatchQueue.main.async(){
                        for i in 0..<self.count{
                            let recipeImage = json[i]["recipe_image"].stringValue
                            let type = json[i]["type_id"].stringValue
                            let recipeName = json[i]["recipe_name"].stringValue
                            let time = json[i]["recipe_cookingtime"].stringValue
                            let level = json[i]["recipe_level"].stringValue
                            let description = json[i]["recipe_description"].stringValue
                            let people = json[i]["recipe_people"].stringValue
                            let count = json[i]["favoriteCount"].stringValue
                            let recipeID = json[i]["recipe_id"].stringValue
                            print(i)
                            let data = HomeRecipe()
                            data.recipeName = recipeName
                            data.type = type
                            data.time = time
                            data.level = level
                            data.people = people
                            data.description = description
                            data.count = count
                            data.recipeImage = recipeImage
                            data.recipeID = recipeID
                            self.itemArray.append(data)
                            self.tableview.reloadData()
                        }
                      }
                      
                  }
                  else{
                      
                  }
              }

              task.resume()
          }
    func favoriteApi(id:Int){
                  let url = URL(string: "http://192.168.2.221:3000/recipe/select/favorite")
                  var request = URLRequest(url: url!)
                  request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "ContentType")
                  request.addValue(authtoken, forHTTPHeaderField: "user_authtoken")
                  request.httpMethod = "POST"
                  
        let parameters: [String: Any] = ["favorite":0,"user_email":email,"recipe_id":id]
                  request.httpBody = parameters.percentEncoded()
                  
                  let task = URLSession.shared.dataTask(with: request) { data, response, error in
                      guard let data = data,
                          let response = response as? HTTPURLResponse,
                          error == nil else {
                          print("error", error ?? "Unknown error")
                          return
                      }

                      guard (200 ... 299) ~= response.statusCode else {
                          print("statusCode should be 2xx, but is \(response.statusCode)")
                          print("response = \(response)")
                          return
                      }
                      let json = try! JSON(data: data)
                      let responseString = String(data: data, encoding: .utf8)
                      print(json)
                      print(responseString!)
                    
                    self.count = json.count
                    print(self.count)
                    let a = json[0]["type_id"].stringValue
                    print(a)
                   
                      if responseString != nil{
                          DispatchQueue.main.async(){
                      
                          }
                          
                      }
                      
                  }

                  task.resume()
              }
    
}
//extension homeViewController : UISearchResultsUpdating{
//    func updateSearchResults(for searchController: UISearchController) {
//
//
////        guard let searchText = searchController.searchBar.text else { return }
////
////        if searchText == ""{
////            print("none")
////        }else{
////            print("search")
////            itemArray = itemArray.filter({ (recipe) -> Bool in
////                recipe.recipeName.contains(searchText)
////            })
////            tableview.reloadData()
////        }
//    }
//
//}