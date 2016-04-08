//
//  TableViewCell.swift
//  ImageViewModelExample
//
//  Created by Sergii Gavryliuk on 2016-04-07.
//  Copyright © 2016 Sergey Gavrilyuk. All rights reserved.
//

import Foundation
import UIKit
import ReactiveCocoa
import Result
import ImageViewModel

class UserTableViewCell: UITableViewCell {
    let viewModel = UserItemViewModel()
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userpicImageView: UIImageView!
    
    override func awakeFromNib() {
        self.viewModel.username.producer.startWithNext {[unowned self] username in
            self.usernameLabel.text = username
        }
        
        self.viewModel.userpicViewModel.resultImage.producer.startWithNext {
            [unowned self] image in
            self.userpicImageView.image = image
        }
        
        self.viewModel.userpicViewModel.imageTransitionSignal.observeNext {
            [unowned self] in
            let transition = CATransition()
            transition.type = kCATransitionFade
            self.imageView?.layer.addAnimation(transition, forKey: nil)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.viewModel.userpicViewModel.imageViewSize.value = userpicImageView.frame.size
    }
}


class UserItemViewModel {
    
    let userpicViewModel = ImageViewModel(imageProvider: globalImageProvider)
    let user = MutableProperty<User?>(nil)
    
    var username: AnyProperty<String?>
    
    init() {
        self.username = AnyProperty(initialValue: nil, producer: user.producer.map { $0?.username } )
    }
}