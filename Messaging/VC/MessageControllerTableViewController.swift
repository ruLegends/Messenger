//
//  MessageControllerTableViewController.swift
//  Messaging
//
//  Created by A on 13.05.2020.
//  Copyright © 2020 test. All rights reserved.
//

import UIKit
import Firebase

class MessageControllerTableViewController: UITableViewController {

    @IBAction func onTapBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    let cellId = "cellId"
    var users = [User]()
    var selectetUser = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareTableView()
        fetchUsers()
    }
    
    func fetchUsers() {
     
        Database.database().reference().child("users").observe(.childAdded) { (snapshot) in
            let user = User()
            
            user.id = snapshot.key
            user.email = (snapshot.value as? NSDictionary)?["email"] as? String ?? ""
            user.name = (snapshot.value as? NSDictionary)?["login"] as? String ?? ""
            user.profileImageUrl = (snapshot.value as? NSDictionary)?["profileImageUrl"] as? String ?? ""

            self.users.append(user)
                
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func prepareTableView() {
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        selectetUser = user
        performSegue(withIdentifier: "toChat", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let vc = segue.destination as! ChatLogController
        vc.user = selectetUser
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        
        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        
        
        if let profileImageUrl = user.profileImageUrl {
            cell.profileImageView.loadImageUsingCache(profileImageUrl: profileImageUrl)
        }
        
        return cell
    }
}
