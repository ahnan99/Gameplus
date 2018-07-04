//
//  BetView.swift
//  GamePlus
//
//  Created by LiuYinan on 4/11/17.
//  Copyright © 2017 LiuYinan. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import Foundation


class BetView: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var betHistoryTableView: UITableView!

    @IBOutlet weak var homeLabel: UILabel!
    @IBOutlet weak var awayLabel: UILabel!
    @IBOutlet weak var timeCountDown: UILabel!
    
    @IBOutlet weak var imageH: UIImageView!
    @IBOutlet weak var betHome: UIButton!
    @IBOutlet weak var betAway: UIButton!
    
    
    @IBOutlet weak var imageA: UIImageView!
    var game:Game?
    var betlist:[Bet]=[]
    var p1=0
    var p2=0
    var p1Bet=0;
    var p2Bet=0;
    var sum1=0;
    var sum2=0;
    var rate1:Double=0;
    var rate2:Double=0;
    var name:String="";
    var str:String="";
    var strArray:[String] = []
    
    var counter = 30
    
    override func viewWillAppear(_ animated: Bool) {
        user = FIRAuth.auth()?.currentUser
        ref = FIRDatabase.database().reference()
        readBalance()
        
        fetch()
        
        betHistoryTableView.delegate=self
        betHistoryTableView.dataSource=self
        betHistoryTableView.reloadData()
        
        rateBar.transform=CGAffineTransform(scaleX: 1, y: 4)
        
        
        betHome.layer.cornerRadius = 6
        betAway.layer.cornerRadius = 6
        
        BetActionShow.backgroundColor = UIColor(red: 100.0/255.0, green: 100.0/255.0, blue: 100.0/255.0, alpha: 1.0)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageH.image=teamIcon(teamname:(game?.home)!)
        imageA.image=teamIcon(teamname:(game?.away)!)
        homeLabel.text=game?.home
        awayLabel.text=game?.away
        homeLabel.numberOfLines=0
        awayLabel.numberOfLines=0
        timeCountDown.text="VS"
        
        var _ = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
        
    }
    
    func readBalance() {
        ref.child("userprofiles").child((user?.uid)!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            
            let value = snapshot.value as? NSDictionary
            let pointnow = value?["points"] as? String ?? ""
            let pointnum = Int(pointnow)
            self.navigationItem.title="Points: " + String(describing: pointnum!)
        }){ (error) in
        }
    }
    
    
    func updateCounter() {
        //you code, this is an example
        if counter > 0 {
            counter -= 1
            
        }
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
    


    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return strArray.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "betCell", for: indexPath)
        for v in cell.subviews{
            v.removeFromSuperview()
        }
        
        let labelheight:CGFloat=50
        let label1 = UILabel(frame: CGRect(x: 20, y:cell.frame.size.height-labelheight, width:  cell.frame.width-40, height: labelheight))

        
        // label.center = CGPoint(x: 160, y: 285)
        label1.textAlignment = .center
        label1.text = strArray[indexPath.row]
        label1.numberOfLines=0


        cell.addSubview(label1)

        return cell
    }
    
    
    // database
    var user :FIRUser?
    
    var ref: FIRDatabaseReference!
    
    func fetch() {
        ref.child("comments").child((game?.id)!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            
            let value = snapshot.value as? NSDictionary
            let pHome = value?["betHome"] as? Int ?? 0
            let pAway = value?["betAway"] as? Int ?? 0
            self.p1=pHome
            self.p2=pAway
            self.update()
            
        }){ (error) in
        }
        
        ref.child("comments").child((game?.id)!).child("gameBets").child((user?.uid)!).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            
            let  sum11 = value?["sum1"] as? Int ?? 0
            let  sum22 = value?["sum2"] as? Int ?? 0
            self.sum1=sum11
            self.sum2=sum22
            
        }){ (error) in
        }
        
        ref.child("comments").child((game?.id)!).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            
            let  rate11 = value?["rate1"] as? Double ?? 0
            let  rate22 = value?["rate2"] as? Double ?? 0
            self.rate1=rate11
            self.rate2=rate22

        }){ (error) in
        }
        
        ref.child("comments").child((game?.id)!).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            
            let  strA1 = value?["history"] as? [String] ?? []
            self.strArray=strA1
            self.betHistoryTableView.reloadData()
        }){ (error) in
        }
        
        
        
        
    }
    
    func write() {
        self.ref.child("comments").child(game!.id).child("betHome").setValue(p1)
        self.ref.child("comments").child(game!.id).child("betAway").setValue(p2)
        self.ref.child("comments").child(game!.id).child("gameid").setValue(game!.id)
        
        self.ref.child("comments").child(game!.id).child("rate1").setValue(rate1)
        self.ref.child("comments").child(game!.id).child("rate2").setValue(rate2)
        
        self.ref.child("comments").child(game!.id).child("gameBets").child((user?.uid)!).child("sum1").setValue(sum1)
        self.ref.child("comments").child(game!.id).child("gameBets").child((user?.uid)!).child("sum2").setValue(sum2)
        self.ref.child("comments").child(game!.id).child("gameBets").child((user?.uid)!).child("id").setValue((user?.uid)!)
        
    }
    
    
    
    


    
    @IBOutlet weak var point1: UITextField!
    @IBOutlet weak var rate1Label: UILabel!
    @IBOutlet weak var rate2Label: UILabel!
    @IBOutlet weak var rateBar: UIProgressView!
    @IBOutlet weak var BetActionShow: UILabel!
    
    
    @IBAction func bet1(_ sender: Any) {
        
        fetch()
        
        
        
        ref.child("userprofiles").child((user?.uid)!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            
            let value = snapshot.value as? NSDictionary
            let pointnow = value?["points"] as? String ?? ""
            let pointnum = Int(pointnow)
            if(pointnum!-Int(self.point1.text!)!>=0) {
                if(self.sum2 == 0) {
                    self.p1Bet=Int(self.point1.text!)!
                    self.p1=self.p1+self.p1Bet
                    self.sum1=self.sum1+self.p1Bet
                    self.BetActionShow.text="You have bet \(self.sum1) on the home-team in total"
                    self.ref.child("userprofiles").child((self.user?.uid)!).child("points").setValue(String(pointnum!-self.p1Bet))
                    let alertController = UIAlertController(title: "Bet placed !", message:":)", preferredStyle: .alert)
                    
                    alertController.addAction(UIAlertAction(title: "Back", style: UIAlertActionStyle.destructive, handler: { action in
                        
                        self.readBalance()
                        self.update()
                        self.write()
                        self.fetch()
                        self.update()
                        self.history()
                        
                    }))
                    
                    self.present(alertController, animated: true, completion: nil)
                    
                }
                if(self.sum2 != 0) {
                    
                    let alertController = UIAlertController(title: "Sorry, you have bet on away-team!", message:":(", preferredStyle: .alert)
                    
                    alertController.addAction(UIAlertAction(title: "Back", style: UIAlertActionStyle.destructive, handler: { action in
                        
                    }))
                    
                    self.present(alertController, animated: true, completion: nil)
                }

                //database
                
            }else{
                let alertController = UIAlertController(title: "You can't afford that!", message:":(", preferredStyle: .alert)
                
                alertController.addAction(UIAlertAction(title: "Back", style: UIAlertActionStyle.destructive, handler: { action in
        
                }))
                
                self.present(alertController, animated: true, completion: nil)
            }
            
            
        }){ (error) in
        }
        
        
        
        

    }
    @IBAction func bet2(_ sender: Any) {
        
        fetch()
        
        
        
        ref.child("userprofiles").child((user?.uid)!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            
            let value = snapshot.value as? NSDictionary
            let pointnow = value?["points"] as? String ?? ""
            let pointnum = Int(pointnow)
            if(pointnum!-Int(self.point1.text!)!>=0) {
                if(self.sum1 == 0) {
                    self.p2Bet=Int(self.point1.text!)!
                    self.p2=self.p2+self.p2Bet
                    self.sum2=self.sum2+self.p2Bet
                    self.BetActionShow.text="You have bet \(self.sum2) on the away-team in total"
                    self.ref.child("userprofiles").child((self.user?.uid)!).child("points").setValue(String(pointnum!-self.p2Bet))
                    let alertController = UIAlertController(title: "Bet placed !", message:":)", preferredStyle: .alert)
                    
                    alertController.addAction(UIAlertAction(title: "Back", style: UIAlertActionStyle.destructive, handler: { action in
                        
                        self.readBalance()
                        self.update()
                        self.write()
                        self.fetch()
                        self.update()
                        self.history()
                        
                    }))
                    
                    self.present(alertController, animated: true, completion: nil)

                    
                }
                if(self.sum1 != 0) {
                    let alertController = UIAlertController(title: "Sorry, you have bet on home-team!", message:":(", preferredStyle: .alert)
                    
                    alertController.addAction(UIAlertAction(title: "Back", style: UIAlertActionStyle.destructive, handler: { action in
                        
                    }))
                    
                    self.present(alertController, animated: true, completion: nil)

                    
                }

                //database
                
            }else{
                let alertController = UIAlertController(title: "You can't afford that!", message:":(", preferredStyle: .alert)
                
                alertController.addAction(UIAlertAction(title: "Back", style: UIAlertActionStyle.destructive, handler: { action in
                    
                }))
                
                self.present(alertController, animated: true, completion: nil)
            }
            
        }){ (error) in
        }
    }
    
    //update at viewDidLoad
    func update() {
        rate1=Double(p1)/Double(p1+p2)
        rate2=Double(p2)/Double(p1+p2)
        rate1Label.text=String(format: "%.2f", rate1)
        rate2Label.text=String(format: "%.2f", rate2)
        rateBar.progress=Float(rate1)
    }

    func history() {
        
        fetch()
        
        ref.child("userprofiles").child((user?.uid)!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            
            let value = snapshot.value as? NSDictionary
            let name1 = value?["username"] as? String ?? ""
            
            if(self.sum2==0) {
                self.str = name1 + " bets " + String(self.p1Bet) + " on teamhome"
                self.strArray.append(self.str)
            }
            
            if(self.sum1==0) {
                self.str = name1 + " bets " + String(self.p2Bet) + " on teamaway"
                self.strArray.append(self.str)
            }
            
            self.ref.child("comments").child(self.game!.id).child("history").setValue(self.strArray)
            self.betHistoryTableView.reloadData()
            print(self.strArray)
            
        }){ (error) in
        }
        
        

        
    }

    
    
    
}
