//
//  NetworkSessionTests.swift
//  TestTaskTests
//
//  Created by Dmitry Kh on 14.10.22.
//

import XCTest
import Combine
@testable import TestTask

class NetworkSessionTests: XCTestCase {
  let urlRequest = URLRequest(url: URL(string: "http://some.host.com/endpoint/dataSource")!)
  let urlResponse = HTTPURLResponse(url: URL(string: "http://some.host.com/endpoint/dataSource")!,
                                    statusCode: 200, httpVersion: nil, headerFields: nil )!
  var sessionManager: NetworkSessionManagerProtocol?
  var publisher: AnyPublisher<(data: Data?, progress: Progress, response: URLResponse), URLError>!
  
  override func setUpWithError() throws {
    let configuration = URLSessionConfiguration.default
    configuration.protocolClasses = [MockedURLProtocol<TestResponder>.self]
    sessionManager = DefaultNetworkSessionManager(configuration: configuration)
    publisher = try XCTUnwrap(sessionManager?.downLoadTask(request: urlRequest), "The Session Manager is requred")
  }
  
  override func tearDownWithError() throws {
    TestResponder.mockError = nil
    TestResponder.mockData = nil
    TestResponder.mockResponse = nil
  }
  
  func testLoadingDataSuccess() throws {
    TestResponder.mockResponse = urlResponse
    TestResponder.mockData = Data(repeating: 0, count: TestResponder.mockDataSize)
    let progressCounter = TestResponder.mockDataSize/TestResponder.mockChunkSize
  
    let result = try awaitPublisher(publisher)
  
    let data = try XCTUnwrap(result.data, "Expected data")
    XCTAssertEqual(data, TestResponder.mockData)

    // Amount of progress value changes till 100%
    XCTAssertEqual(result.progress.fractionCompleted, 1.0) // 100%
    XCTAssertEqual(TestResponder.testProgressCounter, progressCounter)
  }
  
  func testLoadingDataFailure_urlError() throws {
    let expectedError = URLError(.networkConnectionLost)
    TestResponder.mockError = expectedError

    do {
    _ = try awaitPublisher(publisher)
    } catch {
      XCTAssertEqual((error as? URLError)?.errorCode, expectedError.errorCode)
      return
    }

    XCTFail("Expected cautch error!")
  }
  
  func testLoadingDataFailure_badResponse() throws {
    
    do {
      _ = try awaitPublisher(publisher)
    } catch {
      XCTAssertEqual((error as? URLError)?.errorCode, URLError(.badServerResponse).errorCode)
      return
    }
    
    XCTFail("Expected cautch error!")
  }
  
  func testLoadingDataFailure_noData() throws {
    TestResponder.mockResponse = urlResponse
    TestResponder.mockData = Data(count: 0)

    do {
      _ = try awaitPublisher(publisher)
    } catch {
      XCTAssertEqual((error as? URLError)?.errorCode, URLError(.dataNotValid).errorCode)
      return
    }
    
    XCTFail("Expected cautch error!")
  }
}

struct TestResponder: MockURLResponder {
  static var mockDataSize = 200
  static var mockChunkSize = 10
  static var mockData: Data?
  static var mockResponse: URLResponse?
  static var mockError: URLError?
  
  static var testProgressCounter = 0

  static func respond(to request: URLRequest) throws -> (data: Data?, response: URLResponse?) {
    if let error = mockError { throw error }
    return (data: mockData, response: mockResponse)
  }
  
  // splits the data to chunks for progress simulation
  static func decoupled(data: Data, to nextChunk: (Data) -> Void) {
    stride(from: 0, to: data.count, by: mockChunkSize)
      .map { data[$0 ..< min($0 + mockChunkSize, data.count)] }
      .forEach {
        nextChunk($0)
        testProgressCounter += 1
      }
  }
}

