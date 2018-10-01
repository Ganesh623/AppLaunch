//
//  AppDelegate.swift
//  AppLaunch
//
//  Created by mac on 22/09/18.
//  Copyright © 2018 Ideabeez. All rights reserved.
//

import UIKit
import GoogleSignIn
import FBSDKCoreKit
import SwiftKeychainWrapper

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print("\(error.localizedDescription)")
        } else {
            // Perform any operations on signed in user here.
            let userId = user.userID                  // For client-side use only!
            let idToken = user.authentication.idToken // Safe to send to the server
            let fullName = user.profile.name
            let email = user.profile.email
            print("UserId: \(userId!), TokenId: \(idToken!), FullName: \(fullName!), Email: \(email!)")
            
            googlesignindata(username: fullName!, useremail: email!, userid: userId!, tokenid: idToken!)
        }
        return
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        print(error)
    }   
    
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
            return GIDSignIn.sharedInstance().handle(url as URL?,
                                                     sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                                     annotation: options[UIApplicationOpenURLOptionsKey.annotation]) ||
        FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
        
    }
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        /* window = UIWindow(frame: UIScreen.main.bounds)
        let sb = UIStoryboard(name: "Main", bundle: nil)
        var initialVC = sb.instantiateViewController(withIdentifier: "Onboarding")
        
        let userdefaults = UserDefaults.standard
        if userdefaults.bool(forKey: "OnboardingCompleted") {
            initialVC = sb.instantiateViewController(withIdentifier: "SignInViewController")
        }
        
        window?.rootViewController = initialVC
        window?.makeKeyAndVisible() */
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        // Initialize sign-in
        GIDSignIn.sharedInstance().clientID = "743922382644-fd9v9gdu2n14t86evprt6rsbe6mfr2b9.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().delegate = self
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates
    }

    
    func googlesignindata(username:String, useremail:String, userid:String, tokenid:String) {
        
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
                
                let gmailUserIdKeychain: Bool = KeychainWrapper.standard.set("\(responsestring)", forKey: "GmailUserId")
                print(gmailUserIdKeychain)
                
                //show home screen after successfully Login
                DispatchQueue.main.async {
                    let mainStoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let homepage = mainStoryboard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
                    self.window?.rootViewController = homepage
                }
            }
        }
        task.resume()
    }

}
