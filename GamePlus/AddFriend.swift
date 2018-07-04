//
//  AddFriend.swift
//  GamePlus
//
//  Created by LiuYinan on 4/22/17.
//  Copyright © 2017 LiuYinan. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth

class AddFriend: UIViewController,UITableViewDelegate,UITableViewDataSource{
    
    var user :FIRUser?
    
    var ref: FIRDatabaseReference!
    
    var results:[User] = []
    
    @IBAction func search(_ sender: UIButton) {
        let sstring=stextfield.text!
        results=[]
        if stextfield.text != ""{
        ref.child("userprofiles").observeSingleEvent(of: .value, with: { (snapshot) in
            if let result = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for child in result {
                    //do your logic and validation here
                    let value = child.value as? NSDictionary
                    let email = value?["email"] as? String ?? ""
                    let username = value?["username"] as? String ?? ""
                    let id = value?["id"] as? String ?? ""
                    let points = value?["points"] as? String ?? ""
                    if id != self.user?.uid{
                        if email.range(of:sstring) != nil{
                            let u=User(id:id,email:email,username:username,points:points)
                            self.results.append(u)
                        }else if username.range(of:sstring) != nil{
                            let u=User(id:id,email:email,username:username,points:points)
                            self.results.append(u)
                        }
                    }
                }
                self.searchresults.reloadData()
                if self.results.count==0{
                let alertController = UIAlertController(title: "Sorry", message: "We can't find anyone.", preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                
                self.present(alertController, animated: true, completion: nil)
                }
                
                
            } else {
                print("no results")
                let alertController = UIAlertController(title: "Sorry", message: "We can't find anyone.", preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                
                self.present(alertController, animated: true, completion: nil)
            }
        }) { (error) in
            print(error.localizedDescription)
            }
        }else{
            let alertController = UIAlertController(title: "Error", message: "Please enter some names.", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBOutlet weak var stextfield: UITextField!
    
    @IBOutlet weak var searchresults: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        user = FIRAuth.auth()?.currentUser
        ref = FIRDatabase.database().reference()
        searchresults.delegate=self
        searchresults.dataSource=self
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 70.0;//Choose your custom row height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultCell", for: indexPath)
        for v in cell.subviews{
            v.removeFromSuperview()
        }
        
        let labelheight:CGFloat=50
        let label1 = UILabel(frame: CGRect(x: 10, y:cell.frame.size.height-labelheight, width:  150, height: labelheight))
        let label2 = UILabel(frame: CGRect(x: 165, y:cell.frame.size.height-labelheight, width:  150, height: labelheight))
        // label.center = CGPoint(x: 160, y: 285)
        
        label1.textAlignment = .left
        label1.text = results[indexPath.row].username
        label1.numberOfLines=0
        label1.font=label1.font.withSize(13)
        
        label2.textAlignment = .left
        label2.text = results[indexPath.row].email
        label2.numberOfLines=0
        label2.font=label2.font.withSize(13)
        
        
        let label3 = UIButton(frame: CGRect(x: cell.frame.size.width-80, y:cell.frame.size.height-labelheight+12, width:  60, height: labelheight/2))
        label3.setTitle("Follow",for: .normal)
        label3.backgroundColor=UIColor.clear
        label3.titleLabel?.font = UIFont(name: "Helvetica", size: 13)
        label3.tag=indexPath.row
        label3.backgroundColor = UIColor.orange
        label3.addTarget(self, action: #selector(self.add(sender:)), for: .touchUpInside)
        label3.layer.cornerRadius = 5
        
        cell.addSubview(label1)
        cell.addSubview(label2)
        cell.addSubview(label3)
        return cell
    }
    
    func add(sender: UIButton!){
        
        let addinguser=results[sender.tag]
        
        ref.child("userprofiles").child((user?.uid)!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            
            let value = snapshot.value as? NSDictionary
            var friendslist = value?["friendslist"] as? [String] ?? []
            print(friendslist)
            var flag = 0
            for q in friendslist{
                if q==addinguser.id{
                    flag = 1
                }
            }
            
            if flag == 0{
                friendslist.append(addinguser.id!)
                let alertController = UIAlertController(title: "Nice", message: "You've followed a new friend.", preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                
                self.present(alertController, animated: true, completion: nil)
            }else{
                let alertController = UIAlertController(title: "Oops", message: "You've already followed him/her.", preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                
                self.present(alertController, animated: true, completion: nil)
            }
            self.ref.child("userprofiles").child((self.user?.uid)!).child("friendslist").setValue(friendslist)
            
            
            
            
        }){ (error) in
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
        
        
    }
  
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
        
    }
    
}
