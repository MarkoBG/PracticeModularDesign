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
    
    func test_load_deliversErrorOnClientError() {
        let anyURL = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: anyURL)
        
        expect(sut, toCompleteWithError: .connectivity) {
            let clientError = NSError(domain: "Error", code: 0, userInfo: nil)
            client.complete(with: clientError)
        }
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let anyURL = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: anyURL)
        
        let samples = [199, 201, 300, 400, 500]
        samples.enumerated().forEach { index, code in
            
            expect(sut, toCompleteWithError: .invalidData) {
                client.complete(withSatutsCode: code, at: index)
            }
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
    
        expect(sut, toCompleteWithError: .invalidData) {
            let invalidJSON = Data.init("invalid json".utf8)
            client.complete(withSatutsCode: 200, data: invalidJSON)
        }
    }
    
    // MARK: - Helpers
    
    private class HTTPClientSpy: HTTPClient {

        private var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
        
        var requestedURLs: [URL] {
            return messages.map { $0.url }
        }
        
        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withSatutsCode code: Int, data: Data = Data(), at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedURLs[index], statusCode: code, httpVersion: nil, headerFields: nil)!
            
            messages[index].completion(.success(data, response))
        }
    }
    
    private func expect(_ sut: RemoteFeedLoader, toCompleteWithError error: RemoteFeedLoader.Error, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        
        var capturedResults = [RemoteFeedLoader.Result]()
        sut.load { capturedResults.append($0) }
        
        action()
        
        XCTAssertEqual(capturedResults, [.failure(error)], file: file, line: line)
    }
    
    private func makeSUT(url: URL = URL(string: "https://a-given-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
}
