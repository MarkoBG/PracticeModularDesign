//
//  FeedLoader.swift
//  PracticeModularDesign
//
//  Created by Marko Tribl on 2/4/21.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedItem])
    case failure(Error)
}

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
