//
//  SignInViewController.swift
//  AppLaunch
//
//  Created by mac on 22/09/18.
//  Copyright © 2018 Ideabeez. All rights reserved.
//

import UIKit
import GoogleSignIn
import FBSDKCoreKit
import FBSDKLoginKit
import SwiftKeychainWrapper

class SignInViewController: UIViewController, GIDSignInUIDelegate, FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var userPasswordTextField: UITextField!
    @IBOutlet weak var forgotPassword: UIButton!
    @IBOutlet weak var googleSignInButton: GIDSignInButton!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("logout")
        //When you call the logOut, the user is logged out of your app. it will not logout you from your fb account. if you want to do so, go into the safari app, you can go Facebook.com and logout of your account.
        let loginManager: FBSDKLoginManager = FBSDKLoginManager()
        loginManager.logOut()
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            print(error)
        } else {
            fetchProfile()
        }
    }
    
    
    let loginButton:FBSDKLoginButton = {
        let button = FBSDKLoginButton()
        button.readPermissions = ["email", "public_profile"]
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signInButton.layer.cornerRadius = 5
        registerButton.layer.cornerRadius = 5
        userNameTextField.borderStyle = UITextBorderStyle.roundedRect
        userPasswordTextField.borderStyle = UITextBorderStyle.roundedRect
        
        loginButton.delegate = self
        loginButton.frame = CGRect(x: 107, y: 447, width: 160, height: 30)
        view.addSubview(loginButton)
        
        if FBSDKAccessToken.current() != nil{
            print("AccessToken:\(String(describing: FBSDKAccessToken.current()))")
            fetchProfile()
        }
    }
    
    @IBAction func googleSignInButton(_ sender: Any) {
        GIDSignIn.sharedInstance().uiDelegate=self
        GIDSignIn.sharedInstance().signIn()
    }
    
    func fetchProfile() {
        let parameters = ["fields": "email, first_name, last_name"]
            FBSDKGraphRequest(graphPath: "me", parameters: parameters).start{ (connection,result,error)-> Void in
                if error != nil {   // Error occured while logging in
                    // handle error
                    print(error!)
                    return
                }
                // Details received successfully
                if let data = result as? [String: AnyObject] {
                    let fbid = data["id"] as! String
                    let firstName  = data["first_name"] as! String
                    let lastName  =  data["last_name"] as! String
                    let fbEmail = data["email"] as! String
                    print ("FbID: \(fbid) FirstName: \(firstName) LastName: \(lastName) FbEmail: \(fbEmail)")
                    //send data to server function
                    self.fbsignindata(username: firstName + " " + lastName, useremail: fbEmail)
                }
                // pass this dictionary object into your model class initialiser
            }
    }
    
    
    
    @IBAction func signInButton(_ sender: Any) {
        print("SignIn button tapped")
        
        // Read the values from textfields
        let userName = userNameTextField.text
        let userPassword = userPasswordTextField.text
        
        let validEmailaddress = isValidEmailAddress(emailAddressString: userName!)
        
        if (userName?.isEmpty)! || (userPassword?.isEmpty)!
        {
            // Dispaly alert message here
            displayMessage(userMessage: "One of the required fields is missing")
            return
        }
        
        if validEmailaddress == false {
            // Dispaly alert message here
            displayMessage(userMessage: "Email Address is Incorrect Format")
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
        
        
        //send HTTP Request to perform SignIn
        let myUrl = URL(string: "http://gaveshan.com/bloggaveshanapp/login.php?useremail=\(userName!)&userpass=\(userPassword!))")
        var request = URLRequest(url: myUrl!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // send the data to server
        let task = URLSession.shared.dataTask(with: request) { (data, response, error: Error?) in
            self.removeActivityIndicator(activityIndicator: myActivityIndicator)
            
            if error != nil {
                self.displayMessage(userMessage: "Could not successfully perform this task. please try again")
                print("error=\(String(describing: error))")
                return
            }
            print("respons: \(response!)")
            
            // convert response send from server side code to a object
            do {
                
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String:Any]
                // we need to check if any data come from json payload
                
                if let parseJSON = json {
                    let userId = parseJSON["ID"] as? String
                    print("User Id: \(userId!)")
                    
                    if (userId?.isEmpty)! {
                        self.displayMessage(userMessage: "Could not load successfully. Perform this request, later")
                        return
                    }
                    
                    DispatchQueue.main.async {
                        let homepage = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
                        let appDelegate = UIApplication.shared.delegate
                        appDelegate?.window??.rootViewController = homepage
                    }
                    
                } else {
                    
                    self.displayMessage(userMessage: "Could not successfully perform this task. please try again")
                }
                
            } catch {
                self.removeActivityIndicator(activityIndicator: myActivityIndicator)
                
                self.displayMessage(userMessage: "Could not perform succesfully")
                print(error)
            }
            
        }
        task.resume()
        
    }
    
    
    @IBAction func registerButton(_ sender: Any) {
        print("Register Button Tapped")
        
        let registerController = self.storyboard?.instantiateViewController(withIdentifier: "SignupViewController") as! SignupViewController
        
        self.present(registerController, animated: true)
    }
    
    @IBAction func forgotPassword(_ sender: Any) {
        
        let forgotPasswordController = self.storyboard?.instantiateViewController(withIdentifier: "PasswordResetViewController") as! PasswordResetViewController
        
        self.present(forgotPasswordController, animated: true)
        
    }
    
    func displayMessage(userMessage:String) -> Void {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "Alert", message: userMessage, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title:"Ok", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            
        }
    }
    
    func removeActivityIndicator(activityIndicator: UIActivityIndicatorView)
    {
        DispatchQueue.main.async {
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
        }
    }
    
    func isValidEmailAddress(emailAddressString: String) -> Bool {
        
        var returnValue = true
        let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
        
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
    
    func fbsignindata(username:String, useremail:String) {
        
        // Send HTTP Request to Register User
        let myUrl = URL(string: "http://gaveshan.com/bloggaveshanapp/registration.php")
        var request = URLRequest(url:myUrl!)
        request.httpMethod = "POST" // Compose a query String
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let googleSigninString = ["user_nicename": username,
                                  "user_email": useremail,
                                  "user_pass": username,] as [String : String]
        
        // converting the details to Json payload with serialization
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: googleSigninString, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
            return
        }
        //send data to server
        let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
            // convert response send from server side code to a object
            if error != nil {
                print("Could not successfully perform this task. please try again")
                print("error=\(String(describing: error))")
                return
            }
            else {
                print("response = \(String(describing: response))")
                let responsestring = String(data: data!, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))! as NSString
                print("responseString = \(String(describing: responsestring))")
                
                let fbUserIdKeychain: Bool = KeychainWrapper.standard.set("\(responsestring)", forKey: "FbUserId")
                print(fbUserIdKeychain)
                
                
                //show home screen when successfully login
                DispatchQueue.main.async {
                    let homepage = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
                    let appDelegate = UIApplication.shared.delegate
                    appDelegate?.window??.rootViewController = homepage
                }
            }
        }
        task.resume()
    }
    
}
