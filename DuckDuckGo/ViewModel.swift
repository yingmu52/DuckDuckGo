//
//  ViewModel.swift
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

class ViewModel: NSObject {
	
	var dataSource = MutableProperty([JSON]())
	var queryString: (String) -> URLRequest = { text in
		let escaped = text.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)!
		let url = URL(string: "http://api.duckduckgo.com/?q=\(escaped)&format=json")
		return URLRequest(url: url!)
	}

	convenience init(signal: Signal<String?, NoError>) {
		self.init()
		let searchResults = signal.skipNil()
			.throttle(0.5, on: QueueScheduler.main)
			.filter { text in return text.characters.count > 0 }
			.flatMap(.latest) { text -> SignalProducer<(Data, URLResponse), AnyError> in
				return self.search(text: text) }
			.map { (data, response) -> [JSON] in return JSON(data: data)["RelatedTopics"].arrayValue }
			.observe(on: QueueScheduler(qos: .default, name: "fetchQ"))
		
		searchResults.observe { array in
			switch array {
			case let .value(array):
				self.dataSource.value = array
			case let .failed(array): print(array)
			case .completed, .interrupted: break
			}
		}
	}
	
	func search(text: String?) -> SignalProducer<(Data, URLResponse), AnyError>{
		guard let searchString = text else { return SignalProducer.empty }
		return URLSession.shared.reactive
			.data(with: queryString(searchString))
			.retry(upTo: 2)
			.flatMapError { error in return SignalProducer.empty }
	}
}

