//
//  Models.swift
//  ImageViewModelExample
//
//  Created by Sergii Gavryliuk on 2016-04-07.
//  Copyright © 2016 Sergey Gavrilyuk. All rights reserved.
//

import Foundation


struct User {
    var username: String
    init(json: [String: AnyObject]) {
        self.username = (json["login"] as? String) ?? ""
    }
}