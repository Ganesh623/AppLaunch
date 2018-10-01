//
//  SignupViewController.swift
//  AppLaunch
//
//  Created by mac on 22/09/18.
//  Copyright © 2018 Ideabeez. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

class SignupViewController: UIViewController {
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var userEmailTextField: UITextField!
    @IBOutlet weak var userMobileNumerTextField: UITextField!
    @IBOutlet weak var signupButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstNameTextField.borderStyle = UITextBorderStyle.roundedRect
        lastNameTextField.borderStyle = UITextBorderStyle.roundedRect
        repeatPasswordTextField.borderStyle = UITextBorderStyle.roundedRect
        passwordTextField.borderStyle = UITextBorderStyle.roundedRect
        userEmailTextField.borderStyle = UITextBorderStyle.roundedRect
        userMobileNumerTextField.borderStyle = UITextBorderStyle.roundedRect
        signupButton.layer.cornerRadius = 6
        
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func registrationCancelButton(_ sender: Any) {
        print("registration cancel")
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func registrationSignUpButton(_ sender: Any) {
        print("registration done")
        
        if (firstNameTextField.text?.isEmpty)! ||
            (lastNameTextField.text?.isEmpty)! ||
            (userEmailTextField.text?.isEmpty)! ||
            (passwordTextField.text?.isEmpty)! ||
            (repeatPasswordTextField.text?.isEmpty)! ||
            (userMobileNumerTextField.text?.isEmpty)!
        {
            // Display alert message
            displayMessage(userMessage: "All fields are required to fill In")
            return
        }
        
        let validEmailAddress = isValidEmailAddress(emailAddressString: userEmailTextField.text!)
        let passwordlength = passwordTextField.text!.count
        
        if validEmailAddress == false {
            // Display alert message
            displayMessage(userMessage: "Email Address is Not Valid")
            return
        }
        
        if (passwordlength <= 8) {
            // Dispaly alert message here
            displayMessage(userMessage: "Oops. Password should contain 9 characters atleast")
            return
        }
        
        if ((passwordTextField.text?.elementsEqual(repeatPasswordTextField.text!))! != true)
        {
            // Display alert message
            displayMessage(userMessage: "Please make sure that passwords match")
            return
        }
        var userMobile = userMobileNumerTextField.text!
        userMobile.insert(contentsOf: "91", at: userMobile.startIndex)
        
        if(userMobile.count) < 12 {
            // Display Message Alert of wron mobile number
            self.displayMessage(userMessage: "Oops. Please Enter 10 digit Mobile Number")
            return
        }
        
        // Create Activity Indicator
        let myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        // Position Activity Indicator in the centre of the view
        myActivityIndicator.center = view.center
        // Hide when its done
        myActivityIndicator.hidesWhenStopped = false
        // Start Animating
        myActivityIndicator.startAnimating()
        // add sub view for activity
        view.addSubview(myActivityIndicator)
    
    // Send HTTP Request to Register User
        let myUrl = URL(string: "http://gaveshan.com/bloggaveshanapp/registration.php")
        var request = URLRequest(url:myUrl!)
        request.httpMethod = "POST" // Compose a query String
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // Create value dictionary to send in payload
        let currentdate = Date()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = formatter.string(from: currentdate)
        
        let postString = ["user_nicename": firstNameTextField.text! + " " + lastNameTextField.text!,
                          "user_email": userEmailTextField.text!,
                          "user_pass": passwordTextField.text!,
                          "user_mobile": userMobile,
                          "user_date": dateString,] as [String : String]
        
        // converting the details to Json payload with serialization
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: postString, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
            displayMessage(userMessage: "Something went wrong. Try again later")
            return
        }
        // send the data to server
        let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            self.removeActivityIndicator(activityIndicator: myActivityIndicator)
            
            if error != nil {
                self.displayMessage(userMessage: "Could not successfully perform this task. please try again")
                print("error=\(String(describing: error))")
                return
            }
            else {
                print("response = \(String(describing: response))")
                let responsestring = String(data: data!, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))! as NSString
                print("responseString = \(String(describing: responsestring))")
                
                let localUserIdKeychain: Bool = KeychainWrapper.standard.set("\(responsestring)", forKey: "LocalUserId")
                print(localUserIdKeychain)
                // let retrievedString: String? = KeychainWrapper.standard.string(forKey: "LocalUserId")
                // print(retrievedString!)
                
            }
        }
        task.resume()
        
        let newViewController = storyboard!.instantiateViewController(withIdentifier: "HomeViewController")
        self.present(newViewController, animated: true, completion: nil)
    }
    
    
    
    func removeActivityIndicator(activityIndicator: UIActivityIndicatorView)
    {
        DispatchQueue.main.async {
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
        }
    }
    
    
    func displayMessage(userMessage:String) -> Void {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "Alert", message: userMessage, preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title:"Ok", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func isValidEmailAddress(emailAddressString: String) -> Bool {
        
        var returnValue = true
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
        
        do {
            let regex = try NSRegularExpression(pattern: emailRegEx)
            let nsString = emailAddressString as NSString
            let results = regex.matches(in: emailAddressString, range: NSRange(location: 0, length: nsString.length))
            
            if results.count == 0
            {
                returnValue = false
            }
            
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            returnValue = false
        }
        
        return  returnValue
    }
        
    
}
