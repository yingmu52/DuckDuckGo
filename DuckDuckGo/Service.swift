//
//  Service.swift
//  DuckDuckGo
//
//  Created by Tony on 2017-08-28.
//  Copyright © 2017 Xinyi Zhuang. All rights reserved.
//

import UIKit
import ReactiveCocoa
import ReactiveSwift
import Result
import SwiftyJSON

struct Service {
    static func search(text: String?) -> SignalProducer<[JSON], AnyError>{
        guard let searchString = text else { return SignalProducer.empty }
        return URLSession.shared.reactive
            .data(with: Router.search(searchString).url)
            .retry(upTo: 2)
            .flatMapError { error in return SignalProducer.empty }
            .map { JSON(data: $0.0)["RelatedTopics"].arrayValue }
    }
}

enum Router {
    case search(String)
    var url: URLRequest {
        switch self {
        case .search(let searchText):
            let escaped = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)!
            let url = URL(string: "http://api.duckduckgo.com/?q=\(escaped)&format=json")
            return URLRequest(url: url!)
        }
    }
}
