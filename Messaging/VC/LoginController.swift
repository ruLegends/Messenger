//
//  LoginController.swift
//  Messaging
//
//  Created by A on 07.05.2020.
//  Copyright © 2020 test. All rights reserved.
//

import UIKit
import Firebase

class LoginController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBAction func onTapLoginButton(_ sender: Any) {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            print("Invalid")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (user, error) in
         
            if error != nil {
                print(error!)
                return
            }
            
            self?.emailTextField.text = nil
            self?.passwordTextField.text = nil
            
            self?.performSegue(withIdentifier: "toMessager", sender: nil)
        }
    }
    
    @IBAction func onTapSigninButton(_ sender: Any) {
        performSegue(withIdentifier: "toRegister", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
