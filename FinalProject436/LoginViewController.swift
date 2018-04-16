//
//  LoginViewController.swift
//  FinalProject436
//
//  Created by Megan Pieczynski on 3/3/18.
//  Copyright © 2018 Megan Pieczynski. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class LoginViewController: UIViewController {
    
    var profile : Profile?

    @IBOutlet weak var loginField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    @IBAction func loginPressed(_ sender: UIButton) {
        Auth.auth().createUser(withEmail: loginField.text!, password: passwordField.text!) { (user, error) in
        
            if (error != nil) {
                if let errCode = AuthErrorCode(rawValue: error!._code) {
            
                    switch errCode {
                    case .invalidEmail:
                        let alert = UIAlertController(title: "Invalid Email", message: "Email needs to be in correct format", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler:nil))
                        self.present(alert, animated: true)
                        print("invalid email")
                    case .emailAlreadyInUse:
                        let alert2 = UIAlertController(title: "Email Already In Use", message: "That email is already taken, please try again", preferredStyle: .alert)
                        alert2.addAction(UIAlertAction(title: "OK", style: .default, handler:nil))
                        self.present(alert2, animated: true)
                        print("in use")
                    case .weakPassword:
                        let alert3 = UIAlertController(title: "Weak Password", message: "Please enter a password longer than 6 characters", preferredStyle: .alert)
                        alert3.addAction(UIAlertAction(title: "OK", style: .default, handler:nil))
                        self.present(alert3, animated: true)
                        print("weak password")
                    default:
                        print("Create User Error: \(error!)")
                    }
                }
            }
                
            else {
                let ref =  Database.database().reference()
                var temp = [String]()
                var coupon = [String:String]()
                coupon["temp"] = "temp"
                temp.append("temp")
                let userData = ["Name": self.loginField.text!, "Saved Stores": temp, "Blocked Stores": temp, "Saved Coupons": coupon] as [String : Any]
            
                ref.child("users").child(user!.uid).setValue(userData)
                self.performSegue(withIdentifier: "createSegue", sender: (Any).self)
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barTintColor = hexStringToUIColor(hex: "#9D4B4C")
        self.view.backgroundColor = hexStringToUIColor(hex: "F4EDE9")
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : hexStringToUIColor(hex: "#FFFFFF"), NSAttributedStringKey.font: UIFont(name: "Kefa", size: 20)!]

        // Do any additional setup after loading the view.
    }
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
