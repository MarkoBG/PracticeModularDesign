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
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestDataFromURL() {
        let anyURL = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: anyURL)
        
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [anyURL])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let anyURL = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: anyURL)
        
        sut.load { _ in }
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [anyURL, anyURL])
    }
    
    func test_load_deluversErrorOnClientError() {
        let anyURL = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: anyURL)
        
        var capturedErrors = [RemoteFeedLoader.Error]()
        sut.load { capturedErrors.append($0) }
        
        let clientError = NSError(domain: "Error", code: 0, userInfo: nil)
        client.complete(with: clientError)
        
        XCTAssertEqual(capturedErrors, [.connectivity])
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let anyURL = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: anyURL)
        
        var capturedErrors = [RemoteFeedLoader.Error]()
        sut.load { capturedErrors.append($0) }
        
        client.complete(withSatutsCode: 400)
        
        XCTAssertEqual(capturedErrors, [.invalidData])
    }
    
    // MARK: - Helper
    
    private class HTTPClientSpy: HTTPClient {

        private var messages = [(url: URL, completion: (Error?, HTTPURLResponse?) -> Void)]()
        
        var requestedURLs: [URL] {
            return messages.map { $0.url }
        }
        
        func get(from url: URL, completion: @escaping (Error?, HTTPURLResponse?) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(error, nil)
        }
        
        func complete(withSatutsCode code: Int, at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedURLs[index], statusCode: code, httpVersion: nil, headerFields: nil)
            
            messages[index].completion(nil, response)
        }
    }
    
    private func makeSUT(url: URL = URL(string: "https://a-given-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
}
