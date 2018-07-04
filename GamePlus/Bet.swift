//
//  Bet.swift
//  GamePlus
//
//  Created by LiuYinan on 4/11/17.
//  Copyright © 2017 LiuYinan. All rights reserved.
//

import Foundation
import UIKit
class Bet{
    var text:String?
    var uid:String?
    var points:String?
    
    
    init(text:String,uid:String,points:String) {
        self.text=text
        self.uid=uid
        self.points=points
    }
}
