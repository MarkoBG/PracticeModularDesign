//
//  RemoteFeedLoaderTests.swift
//  PracticeModularDesignTests
//
//  Created by Marko Tribl on 2/5/21.
//

import XCTest

class RemoteFeedLoader {
    
    let client: HTTPClient
    let url: URL
    
    init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    func load() {
        client.get(from: url)
    }
}

protocol HTTPClient {
    func get(from url: URL)
}

class HTTPClientSpy: HTTPClient {
    var requestedURL: URL?
    
    func get(from url: URL) {
        requestedURL = url
    }
}

class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let anyURL = URL(string: "https://a-given-url.com")!
        let client = HTTPClientSpy()
        _ = RemoteFeedLoader(url: anyURL, client: client)
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL() {
        let anyURL = URL(string: "https://a-given-url.com")!
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: anyURL, client: client)
        
            
        sut.load()
        
        XCTAssertEqual(client.requestedURL, anyURL)
    }
}
