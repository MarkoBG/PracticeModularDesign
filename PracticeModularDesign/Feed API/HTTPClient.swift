//
//  HTTPClient.swift
//  PracticeModularDesign
//
//  Created by Marko Tribl on 2/8/21.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
