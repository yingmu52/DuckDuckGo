//
//  ViewController.swift
//  DuckDuckGo
//
//  Created by Xinyi Zhuang on 30/07/2017.
//  Copyright © 2017 Xinyi Zhuang. All rights reserved.
//

import UIKit
import ReactiveCocoa
import ReactiveSwift
import Result
import SwiftyJSON
import SDWebImage

class DuckCell: UITableViewCell {
	@IBOutlet var iconImageView: UIImageView!
	@IBOutlet var textView: UITextView!
}

class ViewController: UIViewController {
	
	@IBOutlet var tableView : UITableView!
	var viewModel = ViewModel()
	lazy var searchBar : UISearchBar = {
		let bar = UISearchBar()
		bar.showsScopeBar = true
		bar.placeholder = "Search DuckDuckGo"
		return bar
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		navigationItem.titleView = searchBar
		
		// create view model
        viewModel.input.searchText <~ self.searchBar.reactive.continuousTextValues.skipNil()
		
		// set up table view
        tableView.reactive.reloadData <~ viewModel.output.dataSource.map { _ in }
		tableView.tableFooterView = UIView(frame: CGRect.zero)
		tableView.estimatedRowHeight = 80
		tableView.rowHeight = UITableViewAutomaticDimension
	}
	
}

extension ViewController: UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel.output.dataSource.value.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "DuckCell") as! DuckCell
		let json = viewModel.output.dataSource.value[indexPath.row]
		cell.textView.text = json["Text"].stringValue
		let imageURL = json["Icon","URL"].stringValue
		if imageURL.characters.count > 0 {
			cell.iconImageView.sd_setImage(with: URL(string: imageURL)!)
		}
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let json = viewModel.output.dataSource.value[indexPath.row]
		guard let url = URL(string: json["FirstURL"].stringValue) else { return }
		UIApplication.shared.open(url, options: [:], completionHandler: nil)
	}
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) { self.searchBar.resignFirstResponder() }
}
