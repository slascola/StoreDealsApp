//
//  RealLoginViewController.swift
//  FinalProject436
//
//  Created by Megan Pieczynski on 3/6/18.
//  Copyright © 2018 Megan Pieczynski. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class RealLoginViewController: UIViewController {
    @IBOutlet weak var userField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBAction func loginButton(_ sender: UIButton) {
        Auth.auth().signIn(withEmail: userField.text!, password: passwordField.text!) { (user, error) in
            
            if (error != nil) {
                if let errCode = AuthErrorCode(rawValue: error!._code) {
                    
                    switch errCode {
                    case .userNotFound:
                        let alert = UIAlertController(title: "Invalid Email", message: "This email does not exist", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler:nil))
                        self.present(alert, animated: true)
                        print("invalid email")
                    case .wrongPassword:
                        let alert2 = UIAlertController(title: "Incorrect Password", message: "Incorrect password, please try again", preferredStyle: .alert)
                        alert2.addAction(UIAlertAction(title: "OK", style: .default, handler:nil))
                        self.present(alert2, animated: true)
                        print("in use")
                    default:
                        print("Sign In Error: \(error!)")
                    }
                }
            }
            else {
                self.performSegue(withIdentifier: "loginSegue", sender: (Any).self)
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
