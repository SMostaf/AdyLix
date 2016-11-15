//
//  LoginController.swift
//  
//
//  Created by Sahar Mostafa (Intel) on 11/13/16.
//
//

import Foundation
import FBSDKCoreKit
import FBSDKLoginKit

import UIKit

class LoginController:  UIViewController, FBSDKLoginButtonDelegate {
    

    override func viewDidLoad() {
        super.viewDidLoad()
        if (FBSDKAccessToken.current() == nil) {
            let loginButton = FBSDKLoginButton()
            
            loginButton.readPermissions = ["public_profile", "email", "user_friends"]
        
            loginButton.center = self.view.center;
            
            loginButton.delegate = self
        
            self.view.addSubview(loginButton)
        } else {
            self.performSegue(withIdentifier: "tabView", sender: self)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if (error == nil) {
            self.performSegue(withIdentifier: "tabView", sender: self)
        }
//        if ((error) != nil)
//        {
//            // Process error
//        }
//        else if result.isCancelled {
//            // Handle cancellations
//        }
//        else {
//            // If you ask for multiple permissions at once, you
//            // should check if specific permissions missing
//            if result.grantedPermissions.contains("email")
//            {
//                // Do work
//            }
//        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
    
    }
}
