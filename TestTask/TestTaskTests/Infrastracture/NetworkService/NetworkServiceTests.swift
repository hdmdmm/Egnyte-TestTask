//
//  NetworkServiceTests.swift
//  TestTaskTests
//
//  Created by Dmitry Kh on 16.10.22.
//

import XCTest
import Combine
@testable import TestTask

class NetworkServiceTests: XCTestCase {
  var mockedSessionManager: MockNetworkSessionManager?
  var networkService: DefaultNetworkService?
  
  override func setUpWithError() throws {
    let mockedSessionManager = MockNetworkSessionManager()
    networkService = try XCTUnwrap( DefaultNetworkService(sessionManager: mockedSessionManager),
                                    "The tests require DefaultNetworkService")
    self.mockedSessionManager = mockedSessionManager
  }
  
  override func tearDownWithError() throws {
    
  }
  
  func testNetworkService_failedStatusCode() throws {
    let url = try XCTUnwrap(
      URL(string: "http://some.host.com/endpoint/path/dataSourceFileName"), "Couldn't create an URL" )
    let response = try XCTUnwrap(
      HTTPURLResponse(url: url, statusCode: 404, httpVersion: nil, headerFields: nil), "Couldn't create a response" )
    mockedSessionManager?.mockAnswer = (data: nil, progress: Progress(), response:  response)
    
    let request = MockRequest(url: url)
    let publisher = try XCTUnwrap(
      networkService?.request(endpoint: request), "The network service reference is not valid" )
    do {
      _ = try awaitPublisher(publisher)
    }
    catch {
      XCTAssertEqual(error as? NetworkError, NetworkError.error(statusCode: 404, data: nil))
      return
    }
    XCTFail("The test should caught the error")
  }

  func testNetworkService_notConnectedToInternet() throws {
    let mockError = URLError(.notConnectedToInternet)
    try handleFailureCase(with: mockError, and: NetworkError.notConnected)
  }
  
  func testNetworkService_networkConnectionLost() throws {
    let mockError = URLError(.networkConnectionLost)
    try handleFailureCase(with: mockError, and: NetworkError.notConnected)
  }

  func testNetworkService_cancel() throws {
    let mockError = URLError(.cancelled)
    try handleFailureCase(with: mockError, and: NetworkError.cancelled)
  }

  func testNetworkService_badURL() throws {
    let mockError = URLError(.badURL)
    try handleFailureCase(with: mockError, and: NetworkError.urlGeneration)
  }

  func testNetworkService_unsupportedURL() throws {
    let mockError = URLError(.unsupportedURL)
    try handleFailureCase(with: mockError, and: NetworkError.urlGeneration)
  }
  
  func testNetworkService_generalError() throws {
    let mockError = URLError(.dataNotValid)
    try handleFailureCase(with: mockError, and: NetworkError.generic(mockError))
  }

  func testNetworkService_success() throws {
    let url = try XCTUnwrap(
      URL(string: "http://some.host.com/endpoint/path/dataSourceFileName"), "Couldn't create URL" )
    let request = MockRequest(url: url)
    let response = try XCTUnwrap(
      HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil), "Couldn't create a response" )
    let data = Data(repeating: 0, count: 200)
    
    mockedSessionManager?.mockAnswer = (data: data,
                                        progress: Progress(totalUnitCount: 200, parent: Progress(), pendingUnitCount: 0),
                                        response: response)
    let publisher = try XCTUnwrap(
      networkService?.request(endpoint:request), "The network reference is not valid")
    let result = try awaitPublisher(publisher)
    let resultData = try XCTUnwrap(result.0, "Expected the data")

    XCTAssertEqual(resultData, data)
  }
 
  // MARK: private API helper
  private func handleFailureCase( with error: URLError, and expected: NetworkError,
                                  file: StaticString = #file, line: UInt = #line) throws {
    mockedSessionManager?.mockError = error

    let url = try XCTUnwrap(
      URL(string: "http://some.host.com/endpoint/path/dataSourceFileName"), "Couldn't create an URL",
      file: file, line: line )
    let request = MockRequest(url: url)
    let publisher = try XCTUnwrap(
      networkService?.request(endpoint: request), "The network service reference is not valid" ,
      file: file, line: line )
    do {
      _ = try awaitPublisher(publisher)
    }
    catch {
      XCTAssertEqual((error as? NetworkError), expected, file: file, line: line)
      return
    }
    XCTFail("The test should caught the error", file: file, line: line)
  }
}

struct MockRequest: Request {
  var url: URL
}

class MockNetworkSessionManager: NetworkSessionManagerProtocol {
  var mockAnswer: (data: Data?, progress: Progress, response: URLResponse)?
  var mockError: URLError?
  
  var testDownloadTaskCalled = false

  func downLoadTask(request: URLRequest) -> AnyPublisher<(data: Data?, progress: Progress, response: URLResponse), URLError> {
    if let error = mockError {
      return Fail(error: error).eraseToAnyPublisher()
    }
    
    guard let answer = mockAnswer else {
      return Fail(error: URLError( .failedTest_theAnswerWasNotProvided )).eraseToAnyPublisher()
    }

    return Just(answer).setFailureType(to: URLError.self ).eraseToAnyPublisher()
  }
}

extension URLError.Code {
  public static var failedTest_theAnswerWasNotProvided = URLError.Code( rawValue: -10000 )
}
