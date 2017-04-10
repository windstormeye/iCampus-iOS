//
//  ICNewsTableViewController.swift
//  iCampus
//
//  Created by Bill Hu on 2017/4/6.
//  Copyright © 2017年 BISTU. All rights reserved.
//

import UIKit
import MJRefresh

protocol ICNewsViewCell {
    func update(news: ICNews)
}

protocol ICNewsParentViewController {
    func hideNavigationBar(hide: Bool)
}

class ICNewsTableViewController: UITableViewController {
    
    var delegate: ICNewsParentViewController?
    var page = 1
    var channel: ICNewsChannel
    var news = [ICNews]()
    let nibNames = ["ICNoneImageViewCell", "ICSimpleImageViewCell"]
    
    init(category: String, title: String) {
        channel = ICNewsChannel()
        channel.listKey = category
        channel.title = title
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        super.loadView()
        title = channel.title
        for nibName in nibNames {
            tableView.register(UINib(nibName: nibName, bundle: Bundle.main), forCellReuseIdentifier: nibName)
        }
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = 80//UITableViewAutomaticDimension
        tableView.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.mj_header.beginRefreshing()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return news.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        if news[indexPath.row].imageURL == "" {
            cell = tableView.dequeueReusableCell(withIdentifier: nibNames[0], for: indexPath)
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: nibNames[1], for: indexPath)
        }
        (cell as! ICNewsViewCell).update(news: news[indexPath.row])
        return cell
    }
    
    // MARK: MJRefresh
    internal func refresh() {
        ICNews.fetch(channel, page: 1,
                     success: {
                        [weak self] data in
                        self?.tableView.mj_header.endRefreshing()
                        self?.news = data as! [ICNews]
                        self?.tableView.reloadData()
                        self?.page = 2
            },
                     failure: {
                        [weak self] _ in
                        self?.tableView.mj_header.endRefreshing()
        })
    }
    
    internal func loadMore() {
        ICNews.fetch(channel, page: page,
                     success: {
                        [weak self] data in
                        self?.tableView.mj_footer.endRefreshing()
                        self?.news.append(contentsOf: data as! [ICNews])
                        self?.tableView.reloadData()
                        self?.page += 1
            },
                     failure: {
                        [weak self] _ in
                            self?.tableView.mj_footer.endRefreshing()
        })
    }
    
    // MARK: Table View Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        navigationController?.pushViewController(<#T##viewController: UIViewController##UIViewController#>, animated: <#T##Bool#>)
    }

}
