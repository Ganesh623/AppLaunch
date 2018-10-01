//
//  PasswordResetViewController.swift
//  AppLaunch
//
//  Created by mac on 22/09/18.
//  Copyright © 2018 Ideabeez. All rights reserved.
//

import UIKit

class PasswordResetViewController: UIViewController {

    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var mobileNumberTextField: UITextField!
    @IBOutlet weak var forgotPasswordNote: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        newPasswordTextField.borderStyle = UITextBorderStyle.roundedRect
        mobileNumberTextField.borderStyle = UITextBorderStyle.roundedRect
        confirmButton.layer.cornerRadius = 6
        
        // Do any additional setup after loading the view.
    }

    @IBAction func backToSignIn(_ sender: Any) {
        let backtosign = self.storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
        self.present(backtosign, animated: true, completion: nil)
    }
    
    @IBAction func forgotPasswordSubmitButton(_ sender: Any) {
        
        let mobilenumber = mobileNumberTextField.text
        let newpassword = newPasswordTextField.text
        
        
        if(mobilenumber?.count)! < 10 {
                // Display Message Alert of wron mobile number
                self.displayMessage(userMessage: "Oops. Please Enter 10 digit Mobile Number")
                return
        }
        
        if (mobilenumber?.isEmpty)! || (newpassword?.isEmpty)! {
            
            // Display Message Alert of wron mobile number
            self.displayMessage(userMessage: "Oops. Both fields are mandatory")
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
        
        let myurl = URL(string: "http://localhost:8080/api/user")
        var request = URLRequest(url: myurl!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // Create value dictionary to send in payload
        let postString = ["userMobile": mobilenumber!,
                          "newPassword": newpassword!,] as [String : String]
        
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
            
            // convert response send from server side code to a object
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [String:Any]
                
                if let parseJSON = json {
                    
                    let userId = parseJSON["userId"] as? String
                    print("User id: \(String(describing: userId!))")
                    
                    if (userId?.isEmpty)! {
                        self.displayMessage(userMessage: "Could not perform succesfully")
                        return
                    } else {
                        self.displayMessage(userMessage: "succesfully Updated")
                    }
                    
                }
                else {
                    self.displayMessage(userMessage: "Could not get the response successfully")
                }
            }
            catch {
                self.removeActivityIndicator(activityIndicator: myActivityIndicator)
                
                self.displayMessage(userMessage: "Could not perform succesfully")
                print(error)
            }
        }
        
        task.resume()
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
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
