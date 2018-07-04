//
//  Game.swift
//  GamePlus
//
//  Created by LiuYinan on 4/10/17.
//  Copyright © 2017 LiuYinan. All rights reserved.
//

import Foundation
import UIKit

class Game:NSObject{
    var home:String
    var away:String
    var score:String
    var schedule:String
    var id:String
    var status:String
    var winteam:String
    
    
    init(home:String="", away:String="",score:String="",schedule:String="",id:String="",status:String="",winteam:String="") {
        self.home = home
        self.away = away
        self.score = score
        self.schedule = schedule
        self.id = id
        self.status = status
        self.winteam=winteam
    }
    
    
}
