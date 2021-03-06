//
//  ViewController.swift
//  ImageViewModelExample
//
//  Created by Sergii Gavryliuk on 2016-04-07.
//  Copyright © 2016 Sergey Gavrilyuk. All rights reserved.
//

import UIKit
import ReactiveCocoa
import Result

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    let usersListViewModel = UsersListViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usersListViewModel.usersList.producer.startWithNext { [unowned self] users in
            self.tableView.reloadData()
        }
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.usersListViewModel.usersList.value.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! UserTableViewCell
        cell.viewModel.user.value = self.usersListViewModel.usersList.value[indexPath.row]
        return cell
    }
}

class UsersListViewModel {
    let usersList: AnyProperty<[User]>
    
    init() {
        let usersSignal = SignalProducer<[[String:AnyObject]], NSError> { sink, disposables in
            let task = NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: "https://api.github.com/users")!) {
                data, response, maybeError in
                if let error = maybeError {
                    sink.sendFailed(error)
                } else {
                    do {
                        let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                        sink.sendNext((json as! [AnyObject]).map { $0 as! [String: AnyObject] } )
                        sink.sendCompleted()
                    } catch let error as NSError {
                        sink.sendFailed(error)
                    }
                }
            }
            task.resume()
            disposables += ActionDisposable { task.cancel() }
        }
        .flatMapError {_ in return SignalProducer<[[String:AnyObject]], NoError>.empty }
        .map { $0.map(User.init) }
        .observeOn(UIScheduler())
        
        self.usersList = AnyProperty(initialValue: [], producer: usersSignal)
    }
}







