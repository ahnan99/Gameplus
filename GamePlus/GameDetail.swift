//
//  HomeViewController.swift
//  GamePlus
//
//  Created by LiuYinan on 4/10/17.
//  Copyright © 2017 LiuYinan. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth


class GameDetail: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var commentTableView: UITableView!
    @IBOutlet weak var betButton: UIButton!
    
    @IBOutlet weak var imageH: UIImageView!
    
    @IBOutlet weak var imageA: UIImageView!
    @IBOutlet weak var cmtextfield: UITextField!
    @IBOutlet weak var homelabel: UILabel!
    
    @IBOutlet weak var awaylabel: UILabel!
    var game:Game?
    var commentlist:[Comment]=[]
    var str:String=""
    @IBOutlet weak var vslabel: UILabel!
    
    
    @IBAction func makecomment(_ sender: UIButton) {
        
        var cmnum:Int?
        let gameid=game?.id
        let userid=FIRAuth.auth()?.currentUser?.uid
        ref.child("comments").child(gameid!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            cmnum = value?["total"] as? Int ?? 0
            
            let cmid=String(cmnum!+1)
            if self.cmtextfield.text! == ""{
                
            }
            else{
                let comment=[self.cmtextfield.text!,userid,self.datenow()]
            
                self.ref.child("comments").child(gameid!).child(cmid).setValue(comment)
            
                self.ref.child("comments").child(gameid!).child("total").setValue(cmnum!+1)
            }
            // ...
            
            self.loadcomments()
        })
        { (error) in
        }
        
        
        
        self.commentTableView.reloadData()
        
    }
    
    
    
    func loadcomments() {
        let gameid=game?.id
        ref.child("comments").child(gameid!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            self.commentlist=[]
            let value = snapshot.value as? NSDictionary
            let cmnum = value?["total"] as? Int ?? 0
            if cmnum==0{
                let c=Comment(text:"No Comment",username:"",date:"",id:"")
                self.commentlist.append(c)

            }else{
                
            for i in 1...cmnum{
                let cm = value?[String(i)] as? [String] ?? ["","",""]
                
                
                self.ref.child("userprofiles").child(cm[1]).observeSingleEvent(of: .value, with: { (snapshot) in
                    let value = snapshot.value as? NSDictionary
                    let username = value?["username"] as? String ?? ""
                    let c=Comment(text:cm[0],username:username,date:cm[2],id:cm[1])
                    self.commentlist.append(c)
                    self.commentTableView.reloadData()
                })
                { (error) in
                }
                
                
            }
               
            }
            
            // ...
        })
        { (error) in
        }
        

    }
    var user :FIRUser?
    
    var ref: FIRDatabaseReference!
    
    
    override func viewWillAppear(_ animated: Bool) {
        user = FIRAuth.auth()?.currentUser
        ref = FIRDatabase.database().reference()
        
        
        homelabel.text=game?.home
        awaylabel.text=game?.away
        homelabel.numberOfLines=0
        awaylabel.numberOfLines=0
     
        imageH.image=teamIcon(teamname:(game?.home)!)
        imageA.image=teamIcon(teamname:(game?.away)!)
        vslabel.text=game?.score
        if game?.score=="null : null" {vslabel.text="scheduled"}
        
        loadcomments()
        commentTableView.delegate=self
        commentTableView.dataSource=self
        
        commentTableView.allowsSelection = false
        
        
        commentTableView.reloadData()
        
        betButton.layer.cornerRadius=4
        
        
        
    }
    
    
    override func viewDidLoad() {
        if(((game?.score)!) != "scheduled") {
            //BetButton.removeFromSuperview()
        }
        
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentlist.count
        
    }
    
    
    
    func datenow()->String{
        var z:String
        let date = Date()
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        z=String(year)+"/"+String(month)+"/"+String(day)
        return z
    }
    
    
    
    func teamIcon(teamname:String)->UIImage{
        var team=UIImage.init(named: "Images/teams/BRO.png")!
        print(teamname)
        switch teamname {
        case "Brooklyn Nets": team=UIImage.init(named: "Images/teams/BRO.png")!
        case "Atlanta Hawks": team=UIImage.init(named: "Images/teams/ATL.png")!
        case "Boston Celtics": team=UIImage.init(named: "Images/teams/BOS.png")!
        case "Charlotte Hornets": team=UIImage.init(named: "Images/teams/CHA.png")!
        case "Chicago Bulls": team=UIImage.init(named: "Images/teams/CHI.png")!
        case "Cleveland Cavaliers": team=UIImage.init(named: "Images/teams/CLE.png")!
        case "Dallas Mavericks": team=UIImage.init(named: "Images/teams/DAL.png")!
        case "Denver Nuggets": team=UIImage.init(named: "Images/teams/DEN.gif")!
        case "Detroit Pistons": team=UIImage.init(named: "Images/teams/DET.gif")!
        case "Golden State Warriors": team=UIImage.init(named: "Images/teams/GOL.png")!
        case "Houston Rockets": team=UIImage.init(named: "Images/teams/HOU.gif")!
        case "Indiana Pacers": team=UIImage.init(named: "Images/teams/IND.gif")!
        case "LA Clippers": team=UIImage.init(named: "Images/teams/LAC.png")!
        case "Los Angeles Lakers": team=UIImage.init(named: "Images/teams/LAL.png")!
        case "Memphis Grizzlies": team=UIImage.init(named: "Images/teams/MEM.gif")!
        case "Miami Heat": team=UIImage.init(named: "Images/teams/MIA.gif")!
        case "Milwaukee Bucks": team=UIImage.init(named: "Images/teams/MIL.png")!
        case "Minnesota Timberwolves": team=UIImage.init(named: "Images/teams/MIN.png")!
        case "New Orleans Pelicans": team=UIImage.init(named: "Images/teams/NO.png")!
        case "New York Knicks": team=UIImage.init(named: "Images/teams/NY.gif")!
        case "Oklahoma City Thunder": team=UIImage.init(named: "Images/teams/OKC.png")!
        case "Orlando Magic": team=UIImage.init(named: "Images/teams/ORL.gif")!
        case "Philadelphia 76ers": team=UIImage.init(named: "Images/teams/PHI.png")!
        case "Phoenix Suns": team=UIImage.init(named: "Images/teams/PHO.png")!
        case "Portland Trail Blazers": team=UIImage.init(named: "Images/teams/POR.png")!
        case "Sacramento Kings": team=UIImage.init(named: "Images/teams/SAC.png")!
        case "San Antonio Spurs": team=UIImage.init(named: "Images/teams/SAN.png")!
        case "Toronto Raptors": team=UIImage.init(named: "Images/teams/TOR.png")!
        case "Utah Jazz": team=UIImage.init(named: "Images/teams/UTA.png")!
        case "Washington Wizards": team=UIImage.init(named: "Images/teams/WAS.png")!
        default: team=UIImage.init(named: "Images/teams/BRO.png")!
        }
        return team
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 120.0;//Choose your custom row height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath)
        for v in cell.subviews{
          v.removeFromSuperview()
        }

        
        let labelheight:CGFloat=50
        let label1 = UILabel(frame: CGRect(x: 20, y:cell.frame.size.height-2*labelheight, width:  cell.frame.size.width-40, height: labelheight))
        let label2 = UILabel(frame: CGRect(x: 40, y:cell.frame.size.height-1*labelheight, width:  140, height: labelheight))
        // label.center = CGPoint(x: 160, y: 285)
        label1.textAlignment = .center
        label1.text = commentlist[indexPath.row].text
        label1.numberOfLines=0
        label1.font = label1.font.withSize(20)
        label1.backgroundColor = UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1.0)
        label1.layer.masksToBounds = true
        label1.layer.cornerRadius=10
        
        
        label2.textAlignment = .left
        label2.text = commentlist[indexPath.row].username
        label2.font = label2.font.withSize(12)
        label2.numberOfLines=0
        
        let label3 = UILabel(frame: CGRect(x: cell.frame.size.width/2, y:cell.frame.size.height-labelheight, width:  80, height: labelheight))
        label3.textAlignment = .left
        label3.text = commentlist[indexPath.row].date
        label3.font = label3.font.withSize(12)
        label3.numberOfLines=0
        
        let delete = UIButton(frame: CGRect(x: cell.frame.size.width-60, y:cell.frame.size.height-labelheight+15, width:  40, height: labelheight/2.5 ))
        delete.titleLabel?.font = label3.font.withSize(12)
        delete.setTitle("Delete", for: .normal)
        delete.backgroundColor=UIColor(red: 150.0/255.0, green: 190.0/255.0, blue: 250.0/255.0, alpha: 1.0)
        delete.layer.cornerRadius=3
        
        delete.addTarget(self, action: #selector(self.deleteComment(sender:)), for: .touchUpInside)
        cell.addSubview(label1)
        cell.addSubview(label2)
        cell.addSubview(label3)
        
        if commentlist[indexPath.row].id==user?.uid{
            cell.addSubview(delete)
            delete.tag=indexPath.row
            
        }
        return cell
    }
    
    
    func myDeleteFunction(secondTree: String) {
        
        ref.child("comments").child((game?.id)!).child(secondTree).removeValue { (error, ref) in
            if error != nil {
                print("error \(error)")
            }
        }
    }
    
    
    func deleteComment(sender: UIButton!) {
        for i in 0..<commentlist.count{
            myDeleteFunction(secondTree: String(i+1))
        }
        
        commentlist.remove(at: sender.tag)
        
        for i in 0..<commentlist.count{
            let comment1=[commentlist[i].text,commentlist[i].id,commentlist[i].date]
            self.ref.child("comments").child((game?.id)!).child(String(i+1)).setValue(comment1)
        }
        
        self.ref.child("comments").child((game?.id)!).child("total").setValue(commentlist.count)
        commentTableView.reloadData()
        
        let alertController = UIAlertController(title: "Comment Deleted", message: "Please have fun :)", preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
        
        self.present(alertController, animated: true, completion: nil)
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "showBetView") {
                let detailedVC = (segue.destination as! BetView)
                detailedVC.game = game
        }
    }
    
    
    
    
    
}
