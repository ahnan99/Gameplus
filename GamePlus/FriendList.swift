//
//  FriendList.swift
//  GamePlus
//
//  Created by LiuYinan on 4/22/17.
//  Copyright © 2017 LiuYinan. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth

class FriendList:UIViewController,UITableViewDataSource,UITableViewDelegate{
    var friends:[User]=[]
    var user :FIRUser?
    var ref: FIRDatabaseReference!
    var storageRef: FIRStorageReference!
    var storage: FIRStorage!
    var uids: [String] = []
    var imageArr: [UIImage] = []
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
        
        
    }
    
    @IBOutlet weak var friendTableview: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 70.0;//Choose your custom row height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath)
        for v in cell.subviews{
            v.removeFromSuperview()
        }
        
        
        let labelheight:CGFloat=50
        let label1 = UILabel(frame: CGRect(x: 100, y:cell.frame.size.height-labelheight, width:  150, height: labelheight))
        let label2 = UILabel(frame: CGRect(x: cell.frame.size.width-140, y:cell.frame.size.height-labelheight, width:  150, height: labelheight))
        let image1 = UIImageView(frame: CGRect(x: 30, y:cell.frame.size.height-labelheight, width:  50, height: 50))
        image1.image = fetchImage(uid: uids[indexPath.row])
        //image1.image = UIImage.init(named: "Images/default.jpg")!
        cell.addSubview(image1)
        // label.center = CGPoint(x: 160, y: 285)
        label1.textAlignment = .center
        label1.text = friends[indexPath.row].username
        label1.numberOfLines=0
        label2.textAlignment = .center
        label2.text = "Points: " + friends[indexPath.row].points!
        label2.numberOfLines=0
 
        cell.addSubview(label1)
        cell.addSubview(label2)
        return cell
    }
    
    func fetchFriends(){
        uids = []
        imageArr=[]
        friends=[]
        ref.child("userprofiles").child((user?.uid)!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            
            let value = snapshot.value as? NSDictionary
            let ids = value?["friendslist"] as? [String] ?? []
            
            self.ref.child("userprofiles").observeSingleEvent(of: .value, with: { (snapshot) in
                if let result = snapshot.children.allObjects as? [FIRDataSnapshot] {
                    for child in result {
                        for id in ids{
                            
                            let value = child.value as? NSDictionary
                            let email = value?["email"] as? String ?? ""
                            let username = value?["username"] as? String ?? ""
                            let idfromchild = value?["id"] as? String ?? ""
                            let points = value?["points"] as? String ?? ""
                            if id == idfromchild{
                                self.friends.append(User(id:id,email:email,username:username,points:points))
                            }
                            
                            self.uids.append(id)
                        }
                        
                    }
                 self.friendTableview.reloadData()
                } else {
                    print("no results")
                }
            }) { (error) in
                print(error.localizedDescription)
            }
        }){ (error) in
        }

        
    }
    
    
    func fetchImage(uid:String) -> UIImage{
       
        
        let filePath = "\(uid)/\("userPhoto")"
        let islandRef = storageRef.child(filePath)
        var im:UIImage = UIImage.init(named: "Images/default.jpg")!
        
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        islandRef.data(withMaxSize: 2 * 1024 * 1024) { data, error in
            if let error = error {
                // Uh-oh, an error occurred!
            } else {
                // Data for "images/island.jpg" is returned
                let image = UIImage(data: data!)
                
                im = image!
                
            }
        }
        return im
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            friends.remove(at: indexPath.row)
            myDeleteFunction()
            var temp:[String]=[]
            for f in friends{
                temp.append(f.id!)
            }
            
            ref.child("userprofiles").child((user?.uid)!).child("friendslist").setValue(temp)
            friendTableview.reloadData()
            let alertController = UIAlertController(title: "NOOOO", message: "You lost a friend. :(", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
            
            
        }
    }
    
    func myDeleteFunction() {
        
        ref.child("userprofiles").child((user?.uid)!).child("friendslist").removeValue { (error, ref) in
            if error != nil {
                print("error \(error)")
            }
        }
    }

    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Unfollow"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        user = FIRAuth.auth()?.currentUser
        ref = FIRDatabase.database().reference()
        storage = FIRStorage.storage()
        storageRef = storage.reference()
        fetchFriends()
        
        
    }
    
    override func viewDidLoad() {
        friendTableview.delegate=self
        friendTableview.dataSource=self
    }
    
    
}
    
