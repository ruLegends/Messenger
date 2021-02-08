//
//  MainViewController.swift
//  Messaging
//
//  Created by A on 06.05.2020.
//  Copyright © 2020 test. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userProfileImage: UIImageView!

    @IBAction func onTapMessageButton(_ sender: Any) {
        performSegue(withIdentifier: "toMessange", sender: nil)
    }
    
    @IBAction func onTapLogOutButton(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            }
        catch let logoutError {
            print(logoutError)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    let cellId = "cellId"
    var messages = [Message]()
    var selectetUser = User()
    var isMessageButtonTapped = false
    var messagesDictionary = [String: Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareTableView()
        prepareProfileInfoFromDB()
        observeUserMessages()
    }
    
    private func prepareTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UserCell.self , forCellReuseIdentifier: cellId)
    }
    
    func prepareProfileInfoFromDB() {
        messages.removeAll()
        messagesDictionary.removeAll()
        tableView.reloadData()
        
        let uid = Auth.auth().currentUser?.uid
        
        Database.database().reference().child("users").child(uid!).observeSingleEvent(of: .value) { (snapshot) in
            let user = User()
            user.name = (snapshot.value as? NSDictionary)?["login"] as? String ?? ""
                
            self.prepareHeader(user: user)
        }
    }
    
    func prepareHeader(user: User) {
        self.userNameLabel.text = user.name
        if let profileImageUrl = user.profileImageUrl {
            self.userProfileImage.loadImageUsingCache(profileImageUrl: profileImageUrl)
        }
    }
    
    func observeUserMessages() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let ref = Database.database().reference().child("user-messages").child(uid)
        
        ref.observe(.childAdded, with: { (snapshot) in
            let messageId = snapshot.key
            let messagesRef = Database.database().reference().child("messages").child(messageId)
            
            self.setupMessages(messagesRef: messagesRef)
            
        }) { (error) in
           print(error)
           return
        }
    }
    
    func setupMessages(messagesRef: DatabaseReference) {
        messagesRef.observeSingleEvent(of: .value) { (snapshot) in
            let message = Message()
            
            message.fromId = (snapshot.value as? NSDictionary)?["fromId"] as? String ?? ""
            message.toId = (snapshot.value as? NSDictionary)?["toId"] as? String ?? ""
            message.text = (snapshot.value as? NSDictionary)?["text"] as? String ?? ""
            message.timestamp = (snapshot.value as? NSDictionary)?["timestamp"] as? NSNumber
            
                
            if let chatPartherId = message.chatPartherId() {
                self.messagesDictionary[chatPartherId] = message
                    
                self.messages = Array(self.messagesDictionary.values)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        guard let chatPartnerId = message.chatPartherId() else {return}
        
        let ref = Database.database().reference().child("users").child(chatPartnerId)
        ref.observeSingleEvent(of: .value) { (snapshot) in
            let user = User()
            user.id = chatPartnerId
            user.email = (snapshot.value as? NSDictionary)?["email"] as? String ?? ""
            user.name = (snapshot.value as? NSDictionary)?["login"] as? String ?? ""
            user.profileImageUrl = (snapshot.value as? NSDictionary)?["profileImageUrl"] as? String ?? ""
            
            self.selectetUser = user
            self.isMessageButtonTapped = true
            self.performSegue(withIdentifier: "toChatMain", sender: nil)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if isMessageButtonTapped {
            isMessageButtonTapped = false
            let vc = segue.destination as! ChatLogController
            vc.user = selectetUser
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? UserCell
        
        let message = messages[indexPath.row]
        cell?.message = message
        
        return cell!
    }
}
