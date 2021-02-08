//
//  SignUp.swift
//  Messaging
//
//  Created by A on 24.03.2020.
//  Copyright © 2020 test. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import SwiftKeychainWrapper

class SignUp: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var passwordReplayField: UITextField!
    
    var userUid: String!
    
    @IBAction func onTapCloseButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onTapApplyButton(_ sender: Any) {
        if let email = emailField.text, let password = passwordField.text, let passwordReplay = passwordReplayField.text {
            if password == passwordReplay {
                Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                    if error != nil {
                        //TODO error
                    } else {
                        self.userUid = user?.user.uid
                    }
                    
                }
            } else {
                //TODO alert password != passwordReply
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}
