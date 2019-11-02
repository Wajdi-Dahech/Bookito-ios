//
//  ViewController.swift
//  Bookito
//
//  Created by Katsu on 15/07/2019.
//  Copyright © 2019 Katsu. All rights reserved.
//

import UIKit
import Alamofire
import FBSDKLoginKit
import Firebase
import GoogleSignIn

class ViewController: UIViewController,FBSDKLoginButtonDelegate, GIDSignInUIDelegate,GIDSignInDelegate {
    
    
    
    
     var iduser : String?
    var emailUser = ""
     var nameUser = ""
    var imgUser = ""
  
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print(error.localizedDescription)
            return
        } else {
            guard let authentication = user.authentication else { return }
            let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,accessToken: authentication.accessToken)
            Auth.auth().signInAndRetrieveData(with: credential) { (result, error) in
                if error == nil {
                    
                    //print(result?.user.email as Any)
                    //print(result?.user.displayName as Any)
                   // print(result?.user.photoURL as Any)
                    self.performSegue(withIdentifier: "toHomeScreen", sender: self)
                   
                    self.emailUser = (result?.user.email!)!
                    self.nameUser = (result?.user.displayName!)!
                    self.imgUser = (result?.user.photoURL?.absoluteString)!
                
                    UserDefaults.standard.set(self.nameUser, forKey: "username")
                    UserDefaults.standard.set(self.imgUser, forKey: "userimage")
                    UserDefaults.standard.set(self.emailUser, forKey: "useremail")
                    
                    self.performSegue(withIdentifier: "toHomeScreen", sender: self)
                    
                    
             
                    let parameters: Parameters=[
                        
                        "username":self.nameUser as String,
                        
                        "email":self.emailUser as String,
                        
                        "password":"123",
                        
                        "image":self.imgUser as String
                        
                        
                        
                    ]
                    
                    Alamofire.request("http://localhost:8888/Bookito/register.php", method: .post, parameters: parameters).responseString
                        
                        {
                            
                            response in
                            
                            //printing response
                            
                            print(response)
                            
                            print("ADDED SUCCESSFULY")
                            
                    }
                    //self.userDefault.set(true,forKey: "usersignedin")
                    //self.userDefault.synchronize()
                    //self.window?.rootViewController?.performSegue(withIdentifier: "SegueToSignin", sender: nil)
                    
                }else{ print((error?.localizedDescription) as Any)
                    
                }
            }
        }
    }
    


    @IBOutlet weak var butt: FBSDKLoginButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        butt.delegate = self
        butt.readPermissions = ["public_profile", "email"]
        GIDSignIn.sharedInstance().uiDelegate = self
        let loginButton = FBSDKLoginButton()
        loginButton.center = view.center
        loginButton.delegate = self // Remember to set the delegate of the loginButton
        GIDSignIn.sharedInstance().uiDelegate = self
        
        GIDSignIn.sharedInstance()?.delegate = self

        let googleSignInButton = GIDSignInButton()
        
        googleSignInButton.center = view.center
        
        googleSignInButton.center = CGPoint(x: self.view.center.x, y:550)
        
        view.addSubview((googleSignInButton))
    }
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        
        if error == nil
        {let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
            self.performSegue(withIdentifier: "toHomeScreen", sender: self)
            Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
                print(authResult?.user.email)
               
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
               
                
                
                
            }
            
        }
        else
        { print((error.localizedDescription))
            
        }
        
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
    }
    
}

