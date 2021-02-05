//
//  RemoteFeedLoaderTests.swift
//  PracticeModularDesignTests
//
//  Created by Marko Tribl on 2/5/21.
//

import XCTest
import PracticeModularDesign

class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL() {
        let anyURL = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: anyURL)
        
        sut.load()
        
        XCTAssertEqual(client.requestedURL, anyURL)
    }
    
    // MARK: - Helper
    
    private class HTTPClientSpy: HTTPClient {
        var requestedURL: URL?
        
        func get(from url: URL) {
            requestedURL = url
        }
    }
    
    private func makeSUT(url: URL = URL(string: "https://a-given-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
}
