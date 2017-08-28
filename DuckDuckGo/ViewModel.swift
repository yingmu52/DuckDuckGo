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

protocol ViewModelInput {
    var searchText: MutableProperty<String> {get}
}

protocol ViewModelOutput {
    var dataSource: MutableProperty<[JSON]> {get}
}

protocol ViewModelType {
    var input: ViewModelInput {get}
    var output: ViewModelOutput {get}
}
class ViewModel: ViewModelType, ViewModelInput, ViewModelOutput {
	
    var input: ViewModelInput { return self }
    var output: ViewModelOutput { return self }
    
    var searchText = MutableProperty("")
    var dataSource = MutableProperty([JSON]())
    
    init() {
        let searchResults = searchText.signal
            .throttle(0.5, on: QueueScheduler.main)
            .filter { text in return text.characters.count > 0 }
            .flatMap(.latest) { Service.search(text: $0) }
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
}

