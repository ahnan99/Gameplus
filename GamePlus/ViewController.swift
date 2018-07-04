//
//  ViewController.swift
//  GamePlus
//
//  Created by LiuYinan on 4/9/17.
//  Copyright © 2017 LiuYinan. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth

class ViewController: UIViewController {
    
    var game:Game?
    var user :FIRUser?
    var ref: FIRDatabaseReference!

    @IBOutlet weak var username: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    var handle: FIRAuthStateDidChangeListenerHandle?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ref = FIRDatabase.database().reference()
        handle = FIRAuth.auth()?.addStateDidChangeListener() { (auth, user) in
        // ...
        }
        user = FIRAuth.auth()?.currentUser
        ref = FIRDatabase.database().reference()
        
//        DispatchQueue.global(qos: .userInitiated).async {
//            
//          self.updatePoints()
//            DispatchQueue.main.sync {
//                
//                
//            }
//        }

        updatePoints()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        FIRAuth.auth()?.removeStateDidChangeListener(handle!)
    }
    
    @IBAction func signup(_ sender: UIButton) {
        
        if username.text == "" {
            let alertController = UIAlertController(title: "Error", message: "Please enter your email and password", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            present(alertController, animated: true, completion: nil)
            
        } else {
            FIRAuth.auth()?.createUser(withEmail: username.text!, password: password.text!) { (user, error) in
                
                if error == nil {
                    print("You have successfully signed up")
                    //Goes to the Setup page which lets the user take a photo for their profile picture and also chose a username
                    self.ref.child("userprofiles").child((user?.uid)!).child("points").setValue("100")
                    self.ref.child("userprofiles").child((user?.uid)!).child("username").setValue(user?.email)
                    self.ref.child("userprofiles").child((user?.uid)!).child("email").setValue(user?.email)
                    self.ref.child("userprofiles").child((user?.uid)!).child("id").setValue(user?.uid)
                    
                    
                    let alertController = UIAlertController(title: "You've sucessfully signed up", message:"Click OK to sign in", preferredStyle: .alert)
                    
                    alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.destructive, handler: { action in
                        
                        // do something like...
                        self.signin()
                        
                    }))
                   
                    self.present(alertController, animated: true, completion: nil)
                    
                    
                    
                    //let vc = self.storyboard?.instantiateViewController(withIdentifier: "Home")
                    //self.present(vc!, animated: true, completion: nil)
                    print()
                    
                    
                } else {
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
        
    }
    
    func signin(){
        if self.username.text == "" || self.password.text == "" {
            
            //Alert to tell the user that there was an error because they didn't fill anything in the textfields because they didn't fill anything in
            
            let alertController = UIAlertController(title: "Error", message: "Please enter an email and password.", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
            
        } else {
            
            FIRAuth.auth()?.signIn(withEmail: self.username.text!, password: self.password.text!) { (user, error) in
                
                if error == nil {
                    
                    //Print into the console if successfully logged in
                    print("You have successfully logged in")
                    
                    self.performSegue(withIdentifier: "showhome", sender: nil)
                    //Go to the HomeViewController if the login is sucessful
                    //let vc = self.storyboard?.instantiateViewController(withIdentifier: "Home")
                    //self.present(vc!, animated: true, completion: nil)
                    
                } else {
                    
                    //Tells the user that there is an error and then gets firebase to tell them the error
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func login(_ sender: UIButton) {
        signin()
        //updatePoints()
    }
    @IBOutlet weak var login: UIButton!
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
         override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func getJSON(path: String) -> JSON {
        guard let url = URL(string: path) else { return JSON.null }
        do {
            let data = try Data(contentsOf: url)
            return JSON(data: data as Data)
        } catch {
            return JSON.null
        }
    }
    
    func updatePoints() {
        ref.child("comments").observeSingleEvent(of: .value, with: { (snapshot) in
            if let games = snapshot.children.allObjects as? [FIRDataSnapshot] {
            var gamelist:[String]=[]
            var r1list:[Double]=[]
            var r2list:[Double]=[]
                var flaglist:[Int]=[]
            for child in games {
                let value3 = child.value as? NSDictionary
                let gameid=value3?["gameid"] as? String ?? ""
                let rate1=value3?["rate1"] as? Double ?? 0
                let rate2=value3?["rate2"] as? Double ?? 0
                let flag=value3?["flag"] as? Int ?? 0
                
                gamelist.append(gameid)
                r1list.append(rate1)
                r2list.append(rate2)
                flaglist.append(flag)
                
            }
            print(gamelist)
                
//                var request1:JSON?
//                request1=self.getJSON(path:"https://api.sportradar.us/nba-t3/games/32a8ee31-8528-4227-b281-19ea7f3993ab/summary.json?api_key=ye3tyjk5qhgmygkxm8hebwkf")
//                
//                var request2:JSON?
//                request2=self.getJSON(path:"https://api.sportradar.us/nba-t3/games/92876bc5-7e16-4b32-b710-0afb2f31dfb0/summary.json?api_key=ye3tyjk5qhgmygkxm8hebwkf")
//                
//                let score1=(request1?["home"]["points"])?.int!
//                let score2=(request2?["home"]["points"])?.int!
//                print(score1)
//                print(score2)
                for i in 0..<gamelist.count {
                    
                    if gamelist[i] != "" {
                    var request:JSON?
                    request=self.getJSON(path:"https://api.sportradar.us/nba-t3/games/"+gamelist[i]+"/summary.json?api_key=w7h292w3wxggduccw94s7chh")
                    var nornot=true
                    usleep(1000000)
                        
                    
                       
    
                        
                    let score1=(request?["home"]["points"])?.int!
                    let score2=(request?["away"]["points"])?.int!
                    if score1! == 0 && score2! == 0 && flaglist[i]==0 {
                        print("not started")
                    }
                    else if score1! > score2! && flaglist[i]==0 {
                        print("home win")
                        self.ref.child("comments").child(gamelist[i]).child("gameBets").observeSingleEvent(of: .value, with: { (snapshot) in
                            if let games = snapshot.children.allObjects as? [FIRDataSnapshot] {
                                for child in games {
                                    let value4 = child.value as? NSDictionary
                                    let uid=value4?["id"] as? String ?? ""
                                    let sum1=value4?["sum1"] as? Int ?? 0
                                    self.ref.child("userprofiles").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                                        let value5 = snapshot.value as? NSDictionary
                                        let pt=value5?["points"] as? String ?? ""
                                        
                                        self.ref.child("userprofiles").child(uid).child("points").setValue(String(Int(Double(pt)!+Double(sum1)/(r1list[i]+0.1))))
                                }){ (error) in}
                                    
                                }
                                
                            }
                            
                            self.ref.child("comments").child(gamelist[i]).child("flag").setValue(1)
                            
                        }){ (error) in}
                                
                     
                        
                    }
                    else if flaglist[i]==0 {
                        print("away win")
                        self.ref.child("comments").child(gamelist[i]).child("gameBets").observeSingleEvent(of: .value, with: { (snapshot) in
                            if let games = snapshot.children.allObjects as? [FIRDataSnapshot] {
                                for child in games {
                                    let value4 = child.value as? NSDictionary
                                    let uid=value4?["id"] as? String ?? ""
                                    let sum2=value4?["sum2"] as? Int ?? 0
                                    self.ref.child("userprofiles").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                                        let value5 = snapshot.value as? NSDictionary
                                        let pt=value5?["points"] as? String ?? ""
                                        
                                        self.ref.child("userprofiles").child(uid).child("points").setValue(String(Int(Double(pt)!+Double(sum2)/(r2list[i]+0.1))))
                                        print(pt)
                                    }){ (error) in}
                                    
                                }
                                
                            }
                            
                            self.ref.child("comments").child(gamelist[i]).child("flag").setValue(1)
                            
                        }){ (error) in}
                        
                        
                        }

                    }
                    
                    
                }

                    
            
            }
        }){ (error) in}
    }
}
