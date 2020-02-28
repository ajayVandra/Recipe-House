//
//  profileViewController.swift
//  Recipe House
//
//  Created by Ajay Vandra on 2/25/20.
//  Copyright © 2020 Ajay Vandra. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

let loginEmail = ""
class profileViewController: UIViewController,UINavigationControllerDelegate,UIImagePickerControllerDelegate {

    let userDefault = UserDefaults.standard
    @IBOutlet weak var FirstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var changePassOutlet: UIButton!
    @IBOutlet weak var logoutOutlet: UIButton!
    @IBOutlet weak var profileImage: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileApi()
        print(authtoken)
        print(email)
        imageView()
        buttonLayout()
    }
    func imageView(){
        profileImage.layer.cornerRadius = (profileImage.frame.size.width)/2
        profileImage.clipsToBounds = true
        profileImage.layer.borderWidth = 3.0
        profileImage.layer.borderColor = UIColor.white.cgColor
    }
    func  buttonLayout(){
           changePassOutlet.layer.cornerRadius = changePassOutlet.frame.size.height/2
                  changePassOutlet.layer.borderColor = UIColor.black.cgColor
                  changePassOutlet.layer.borderWidth = 2.0
           logoutOutlet.layer.cornerRadius = logoutOutlet.frame.size.height/2
                  logoutOutlet.layer.borderColor = UIColor.black.cgColor
                  logoutOutlet.layer.borderWidth = 2.0
       }

    @IBAction func selesctProfilePicture(_ sender: UIButton) {
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerController.SourceType.photoLibrary
        image.allowsEditing = true
        present(image, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
            profileImage.image = image
            
        }else{
            print(Error.self)
        }
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func changePasswordButton(_ sender: UIButton) {
  performSegue(withIdentifier: "change", sender: self)
    }
    @IBAction func logoutButton(_ sender: UIButton) {
       self.userDefault.set(false, forKey: "user_authtokenkey")
       self.userDefault.set(authtoken, forKey: "user_authtoken")
        navigationController?.popToRootViewController(animated: true)
    }
    func profileApi(){
        let url = URL(string: "http://192.168.2.221:3000/user/profile")
        var request = URLRequest(url: url!)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue(email, forHTTPHeaderField: "user_email")
        request.addValue(authtoken, forHTTPHeaderField: "user_authtoken")
        request.httpMethod = "POST"
        let parameters: [String: Any] = ["user_email":email]
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
            if responseString != nil{
                DispatchQueue.main.async(){
                    self.FirstNameLabel.text = json["user_firstname"].string
                    self.lastNameLabel.text = json["user_lastname"].string
                    let gender = json["user_gender"]
                    if gender == "m"{
                        self.genderLabel.text = "Male"
                    }else if gender == "f"{
                        self.genderLabel.text = "Female"
                    }
                    self.numberLabel.text = json["user_phone"].stringValue
                    self.emailLabel.text = json["user_email"].string
                }
                
            }
            else{
                
            }
        }

        task.resume()
    }
   
}