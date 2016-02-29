//
//  ViewController.swift
//  devslopes-showcase
//
//  Created by macuser on 2/21/16.
//  Copyright © 2016 ResponseApps. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class ViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
            self.automaticallyAdjustsScrollViewInsets = false
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) != nil {
            self.loggedInSegue()
        }
        
    }
    
    @IBAction func btnFBPressed(sender: UIButton!) {
    
        let facebookLogin = FBSDKLoginManager()
        
        facebookLogin.logInWithReadPermissions(["email"], fromViewController: self) { (facebookResult:FBSDKLoginManagerLoginResult!, facebookError:NSError!) -> Void in
          
            if facebookError != nil {
                print("Facebook login failed. Error \(facebookError)")
            } else {
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                print("Successfully logged in with Facebook \(accessToken)")
                
                DataService.ds.REF_BASE.authWithOAuthProvider("facebook", token: accessToken, withCompletionBlock: { error, authData in
                    
                    //store on device the firebase userID
                    if error != nil {
                        print("login failed \(error)")
                    } else {
                        
                        let user = ["provider": authData.provider!, "keyFOO":"valueBAR"]
                        DataService.ds.createFirebaseUser(authData.uid, user: user)
                        
                        
                        print("logged in!!! \(authData)")
                        NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: KEY_UID)
                        self.loggedInSegue()
                    }
                    
                    
                })
                
            }
            
        }
    
    }

    @IBAction func attemptEmailLogin(sender: UIButton!) {
        if let email = emailField.text where email != "", let pwd = passwordField.text where pwd != "" {
            
            DataService.ds.REF_BASE.authUser(email, password:pwd, withCompletionBlock: { error, authData -> Void in
                if error != nil {
                    
                    if error.code == STATUS_ACCOUNT_NONEXIST {
                        DataService.ds.REF_BASE.createUser(email, password: pwd, withValueCompletionBlock: { error, result -> Void in
                            
                            if error != nil {
                                self.showErrorAlert("Could not create account", msg: "Problem creating account.  Please Play Pac-Man.")
                            } else {
                                NSUserDefaults.standardUserDefaults().setValue(result[KEY_UID], forKey:KEY_UID)
                                
                                DataService.ds.REF_BASE.authUser(email, password: pwd, withCompletionBlock: { err, authData in
                                    
                                    let user = ["provider": authData.provider!, "keyFOOemail":"valueBARemail"]
                                    DataService.ds.createFirebaseUser(authData.uid, user: user)
                                    
    
                                    
                                })

                                self.loggedInSegue()
                            }
                            
                        })
                    } else {
                        self.showErrorAlert("Could not login", msg: "Please check your username and password")
                    }
                    
                } else {
                    self.loggedInSegue()
                }
            })
            
        } else {
            showErrorAlert("Email and Password Required", msg: "You must enter an email and a password")
        }
    }
    
    func showErrorAlert(title: String!, msg: String!) {
        let alert = UIAlertController(title:title, message: msg, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func loggedInSegue() {
        self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
    }
    
}