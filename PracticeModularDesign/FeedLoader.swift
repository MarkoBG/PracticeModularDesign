//
//  FeedLoader.swift
//  PracticeModularDesign
//
//  Created by Marko Tribl on 2/4/21.
//

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    case error(Error)
}

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
