//
//  HomeViewController.swift
//  AppLaunch
//
//  Created by mac on 22/09/18.
//  Copyright © 2018 Ideabeez. All rights reserved.
//

import UIKit
import GoogleSignIn
import FBSDKLoginKit

class HomeViewController: UIViewController {

    @IBAction func didTapSignOut(_ sender: Any) {
        if FBSDKAccessToken.current() != nil {
            let loginManager: FBSDKLoginManager = FBSDKLoginManager()
            loginManager.logOut()

        } else {
            GIDSignIn.sharedInstance().signOut()
        }
        
        let returnController = self.storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
        
        self.present(returnController, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
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
