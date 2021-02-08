//
//  LoginController.swift
//  Messaging
//
//  Created by A on 06.05.2020.
//  Copyright © 2020 test. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class RegisterController: UIViewController {

    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!
    
    override func viewDidLoad() {
        passwordTextField.textContentType = .oneTimeCode
        super.viewDidLoad()
    }
    
    @IBAction func onTapImageRecognizer(_ sender: Any) {
        handlerSelectProfileImage()
    }
    
    @IBAction func onTapApplyButton(_ sender: Any) {
        guard let email = emailTextField.text, let password = passwordTextField.text, let login = loginTextField.text else {
            print("Invalid")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] user, error in
            
            if error != nil {
                print(error!)
                return
            }
            
            guard let uid = user?.user.uid else {
                return
            }
            
            let imageName = NSUUID().uuidString
            let storageRef = Storage.storage().reference().child("profile_images").child("\(imageName).jpeg")
            let image = self?.profileImageView.image
            
            if let uploadData = image?.jpegData(compressionQuality: 0.1) {
                storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
                    
                    if error != nil {
                        print(error!)
                        return
                    }
                    
                    storageRef.downloadURL {[weak self] url, error in
                        if let error = error {
                             print(error)
                        } else {
                            let values = ["login": login, "email": email, "password": password, "profileImageUrl": url?.absoluteString]
                            self?.registerUserIntoDataBaseWithUid(uid: uid,values: values as [String : AnyObject])
                        }
                    }
                }
            }
        }
    }
    
    private func registerUserIntoDataBaseWithUid(uid: String, values: [String: AnyObject]) {
        let ref = Database.database().reference()
        let userReference = ref.child("users/").child(uid)
        
        userReference.updateChildValues(values, withCompletionBlock: { [weak self] (error, ref) in
            
            if error != nil {
                print(error!)
                return
            }
            
            self?.performSegue(withIdentifier: "toMessager", sender: nil)
            print("Saved")
        })
    }
}

extension RegisterController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func handlerSelectProfileImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let orginalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            selectedImageFromPicker = orginalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            profileImageView.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
}
