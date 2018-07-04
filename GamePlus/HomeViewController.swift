//
//  HomeViewController.swift
//  GamePlus
//
//  Created by LiuYinan on 4/10/17.
//  Copyright © 2017 LiuYinan. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth


class HomeViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate {
    

    @IBOutlet weak var gameTableView: UITableView!
    
    
    
   
    var user :FIRUser?
    
    var ref: FIRDatabaseReference!
    
    override func viewDidLoad() {
        fetchgame()
        gameTableView.delegate=self
        gameTableView.dataSource=self
    }
    override func viewWillAppear(_ animated: Bool) {
        user = FIRAuth.auth()?.currentUser
        ref = FIRDatabase.database().reference()
        search.delegate=self
    }
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gameSet.count
        
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
    
    private func getJSON(path: String) -> JSON {
        guard let url = URL(string: path) else { return JSON.null }
        do {
            let data = try Data(contentsOf: url)
            return JSON(data: data as Data)
        } catch {
            return JSON.null
        }
    }
    
    var gameSet:[Game]=[]
    
    func fetchAll(){
        ref.child("comments").observeSingleEvent(of: .value, with: { (snapshot) in
            if let result = snapshot.children.allObjects as? [FIRDataSnapshot] {
                var gamelist:[String]=[]
                for child in result {
                    let value3 = child.value as? NSDictionary
                    let gameid=value3?["gameid"] as? String ?? ""
                    gamelist.append(gameid)
                    
                    
                    
                }
                
                for gameid in gamelist{
                    var request=self.getJSON(path:"https://api.sportradar.us/nba-t3/games/"+gameid+"/summary.json?api_key=ye3tyjk5qhgmygkxm8hebwkf")
                    print(gameid)
                    print(request["id"].string)

                }
            }
            
        }
        ){ (error) in
        }
    }
    
    
    func fetchgame(){
        gameSet=[]
        let date:String=datenow()
        var request:JSON?
        request=getJSON(path:"https://api.sportradar.us/nba-t3/games/"+date+"/schedule.json?api_key=w7h292w3wxggduccw94s7chh")
//        print(request)
        let result=request?["games"].arrayValue.map({$0["id"].stringValue})

        for i in 0..<(result?.count)! {
            let home=(request?["games"][i]["home"]["name"].string)!
            let away=(request?["games"][i]["away"]["name"].string)!
            let score1=(request?["games"][i]["home_points"])!
            let score2=(request?["games"][i]["away_points"])!
            let id=(request?["games"][i]["id"].string)!
            var winteam=""
            var score=String(describing: score1)+" : "+String(describing: score2)
            if score=="null : null" {
                score="scheduled"
            }
            var schedule=(request?["games"][i]["scheduled"].string)!
            let status=(request?["games"][i]["status"].string)!
            var start = schedule.index(schedule.startIndex, offsetBy: 11)
            var end = schedule.index(schedule.endIndex, offsetBy: -6)
            var range = start..<end
            schedule=schedule.substring(with: range)
            
            start = schedule.index(schedule.startIndex, offsetBy: 0)
            end = schedule.index(schedule.endIndex, offsetBy: -6)
            range = start..<end
            var hour=Int(schedule.substring(with: range))
            hour = hour!-5
            if hour! < 0{
                hour = hour!+24
            }
            start = schedule.index(schedule.startIndex, offsetBy: 2)
            end = schedule.index(schedule.endIndex, offsetBy: 0)
            range = start..<end
            schedule=String(describing: hour!)+schedule.substring(with: range)
            
            
            let m:Game=Game(home: home, away: away, score:score,schedule:schedule,id:id,status:status,winteam:winteam)
            print(score)
            gameSet.append(m)
        }
        
        
    }
    
    @IBOutlet weak var search: UISearchBar!
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        if let text=searchBar.text{
            doasearch(text: text)
            
            
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        search.endEditing(true)
    }
    
    func doasearch(text:String) {
            gameSet=[]
            var date:String=text
            if(text=="Today") {date=datenow()}
        
        
            var request:JSON?
            request=getJSON(path:"https://api.sportradar.us/nba-t3/games/"+date+"/schedule.json?api_key=w7h292w3wxggduccw94s7chh")
            //        print(request)

        
            let result=request?["games"].arrayValue.map({$0["id"].stringValue})
        
        if(result?.count==0){
            let alertController = UIAlertController(title: "Sorry, you should check the date", message:":(", preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "Back", style: UIAlertActionStyle.destructive, handler: { action in
                
            }))
            
            self.present(alertController, animated: true, completion: nil)
        }
        
            for i in 0..<(result?.count)! {
                let home=(request?["games"][i]["home"]["name"].string)!
                let away=(request?["games"][i]["away"]["name"].string)!
                let score1=(request?["games"][i]["home_points"])!
                let score2=(request?["games"][i]["away_points"])!
                let id=(request?["games"][i]["id"].string)!
                var winteam=""
                var score=String(describing: score1)+" : "+String(describing: score2)
                if score=="null : null" {
                    score="scheduled"
                }
                var schedule=(request?["games"][i]["scheduled"].string)!
                let status=(request?["games"][i]["status"].string)!
                var start = schedule.index(schedule.startIndex, offsetBy: 11)
                var end = schedule.index(schedule.endIndex, offsetBy: -6)
                var range = start..<end
                schedule=schedule.substring(with: range)
                
                start = schedule.index(schedule.startIndex, offsetBy: 0)
                end = schedule.index(schedule.endIndex, offsetBy: -6)
                range = start..<end
                var hour=Int(schedule.substring(with: range))
                hour = hour!-5
                if hour! < 0{
                    hour = hour!+24
                }
                start = schedule.index(schedule.startIndex, offsetBy: 2)
                end = schedule.index(schedule.endIndex, offsetBy: 0)
                range = start..<end
                schedule=String(describing: hour!)+schedule.substring(with: range)
                
                
                let m:Game=Game(home: home, away: away, score:score,schedule:schedule,id:id,status:status,winteam:winteam)
                print(score)
                gameSet.append(m)
            }
        gameTableView.reloadData()
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
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "gameCell", for: indexPath)
        for v in cell.subviews{
            v.removeFromSuperview()
        }
        
       
        
        
        
        
        
        
        let labelheight:CGFloat=50
        let label1 = UILabel(frame: CGRect(x: 20, y:cell.frame.size.height-labelheight, width:  120, height: labelheight))
        let label2 = UILabel(frame: CGRect(x: cell.frame.size.width-140, y:cell.frame.size.height-labelheight, width:  120, height: labelheight))
        // label.center = CGPoint(x: 160, y: 285)
        
        
        
        
        
        
        label1.textAlignment = .center
        label1.text = gameSet[indexPath.row].home
        label1.numberOfLines=0
        label2.textAlignment = .center
        label2.text = gameSet[indexPath.row].away
        label2.numberOfLines=0
        let label3 = UILabel(frame: CGRect(x: cell.frame.size.width/2-60, y:cell.frame.size.height/2-labelheight, width:  120, height: labelheight))
        label3.textAlignment = .center
        label3.text = gameSet[indexPath.row].score
        if (label3.text=="scheduled") {
            label3.text = "scheduled"+"\n"+gameSet[indexPath.row].schedule
        }
        label3.numberOfLines=0
        
        let imageViewh = UIImageView(frame: CGRect(x: 20, y: 20, width: 120, height: cell.frame.size.height-labelheight-20))
        
        imageViewh.image = teamIcon(teamname:gameSet[indexPath.row].home)
        
        //imageView.image=movieSet?[indexPath.row].image
        
        
        imageViewh.contentMode = UIViewContentMode.scaleAspectFit
        
        cell.addSubview(imageViewh)
        
        let imageViewA = UIImageView(frame: CGRect(x: cell.frame.size.width-20-120, y: 20, width: 120, height: cell.frame.size.height-labelheight-20))
        
        imageViewA.image = teamIcon(teamname:gameSet[indexPath.row].away)
        
        //imageView.image=movieSet?[indexPath.row].image
        
        
        imageViewA.contentMode = UIViewContentMode.scaleAspectFit
        
        cell.addSubview(imageViewA)
        
        
        cell.addSubview(label1)
        cell.addSubview(label2)
        cell.addSubview(label3)
        return cell
    }
    

    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "showDetail") {
            if let indexPath = self.gameTableView.indexPathForSelectedRow{
                let detailedVC = (segue.destination as! GameDetail)
                detailedVC.game = gameSet[(indexPath.row)]
                
                
            }
        }

    
        
    
    
    
    
    
    
    
    
    
//    func fetchgame(searchtitle: String) {
//        
//        let api_key = "5qpbfx53bpnf5jxumd6e9f6d"
//        let date = "040914"
//        let query_string = "api_key="+api_key+"&date="+date;
//        
//        var request = URLRequest(url: URL(string: "https://api.sportradar.us/nba-t3/league/2017/04/09/changes.xml?api_key={5qpbfx53bpnf5jxumd6e9f6d}")!)
//        request.httpMethod = "POST"
//        let postString = query_string
//        request.httpBody = postString.data(using: .utf8)
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            guard let data = data, error == nil else {                                                 // check for fundamental networking error
//                print("error=\(error)")
//                return
//            }
//            
//            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
//                print("statusCode should be 200, but is \(httpStatus.statusCode)")
//                print("response = \(response)")
//            }
//            
//            let responseString = String(data: data, encoding: .utf8)
//            print("responseString = \(responseString)")
//        }
//        task.resume()
//    }
    
    
    
    

    
    }
}
