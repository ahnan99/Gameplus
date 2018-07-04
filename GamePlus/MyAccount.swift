//
//  MyAccount.swift
//  GamePlus
//
//  Created by LiuYinan on 4/11/17.
//  Copyright © 2017 LiuYinan. All rights reserved.
//



import Firebase
import FirebaseAuth
import UIKit
import FirebaseStorage
class MyAccount: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    var user :FIRUser?
    
    var ref: FIRDatabaseReference!
    
    @IBOutlet weak var imageview: UIImageView!
    
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    
    @IBOutlet weak var label3: UILabel!
    var usernamenow:String=""
    
    override func viewWillAppear(_ animated: Bool) {
        user = FIRAuth.auth()?.currentUser
        ref = FIRDatabase.database().reference()
        imageview.layer.borderWidth = 1
        imageview.layer.masksToBounds = false
        imageview.layer.borderColor = UIColor.black.cgColor
        
        imageview.layer.cornerRadius = imageview.frame.height/2
        imageview.clipsToBounds = true
        
        
        ref.child("userprofiles").child((user?.uid)!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let username = value?["username"] as? String ?? ""
            self.usernamenow=username
            let points = value?["points"] as? String ?? ""
            self.usernametext.text=username
            self.label3.text="Current Points: "+points
           
        }){ (error) in
        }
        
        storage = FIRStorage.storage()
        storageRef = storage.reference()

        let filePath = "\(FIRAuth.auth()!.currentUser!.uid)/\("userPhoto")"
        let islandRef = storageRef.child(filePath)
        
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        islandRef.data(withMaxSize: 2 * 1024 * 1024) { data, error in
            if let error = error {
                // Uh-oh, an error occurred!
                
                self.imageview.image=UIImage.init(named: "images/default.jpg")
            } else {
                // Data for "images/island.jpg" is returned
                let image = UIImage(data: data!)
                
                self.imageview.image=image
                
            }
        }
        
        
        
        
        if let user=user{
            label1.text="User Email: "+user.email!
            label2.text="Name :"
        }

        
    }
    
    
    @IBOutlet weak var usernametext: UITextField!
 
    @IBAction func changeName(_ sender: UIButton) {
       
        
        if usernametext.text==""{
            usernametext.text=usernamenow
        }
        else{
            self.ref.child("userprofiles").child((user?.uid)!).child("username").setValue(usernametext.text)
            let alertController = UIAlertController(title: "Wow", message: "Your user name has been changed.", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
            
        }
        usernametext.endEditing(true)
        
    }
    override func viewDidLoad() {
            }
    
    
    
    @IBAction func logout(_ sender: UIButton) {
        
        if FIRAuth.auth()?.currentUser != nil {
            do {
                try FIRAuth.auth()?.signOut()
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "SignUp") as! ViewController
                self.present(vc, animated: true, completion: nil)
                
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        
        
    }
    
    
    var imagePicker = UIImagePickerController()
    
    @IBAction func btnClicked() {
        
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            print("Button capture")
            
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum;
            imagePicker.allowsEditing = false
            
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    var storageRef: FIRStorageReference!
    var storage: FIRStorage!
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
      
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            
            dismiss(animated: true, completion: nil)
            var data = NSData()
            data = UIImageJPEGRepresentation(image, 0.8)! as NSData
            // set upload path
            let filePath = "\(FIRAuth.auth()!.currentUser!.uid)/\("userPhoto")"
            let metaData = FIRStorageMetadata()
            metaData.contentType = "image/jpg"
            self.storageRef.child(filePath).put(data as Data, metadata: metaData){(metaData,error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }else{
                    //store downloadURL
                    let downloadURL = metaData!.downloadURL()!.absoluteString
                    
                    let alert = UIAlertController(title: "Message", message: "Upload Completed", preferredStyle: UIAlertControllerStyle.alert)
                    
                   
                    
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.destructive, handler: { action in
                        
                        // do something like...
                        self.imageview.image = image
                        
                    }))
                     self.present(alert, animated: true, completion: nil)
                    
                    
                    //store downloadURL at database
                  //  self.databaseRef.child("users").child(FIRAuth.auth()!.currentUser!.uid).updateChildValues(["userPhoto": downloadURL])
                }
            
            
            
            }
            
        } else{
            print("Something went wrong")
        }
        
        
    }
    
    
    
    
}
