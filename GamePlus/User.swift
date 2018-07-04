//
//  User.swift
//  GamePlus
//
//  Created by LiuYinan on 4/22/17.
//  Copyright © 2017 LiuYinan. All rights reserved.
//

import Foundation
class User{
    var id:String?
    var email:String?
    var username:String?
    var points:String?
    
    init(id:String,email:String,username:String,points:String){
        self.id=id
        self.email=email
        self.username=username
        self.points=points
        
    }
    
}
