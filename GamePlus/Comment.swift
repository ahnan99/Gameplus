//
//  Comment.swift
//  GamePlus
//
//  Created by LiuYinan on 4/11/17.
//  Copyright © 2017 LiuYinan. All rights reserved.
//

import Foundation
import UIKit
class Comment{
    var text:String?
    var username:String?
    var date:String?
    var id:String
    
    init(text:String,username:String,date:String,id:String) {
        self.text=text
        self.username=username
        self.date=date
        self.id=id
    }
}
