//
//  ImageViewModelTests.swift
//  TestTaskTests
//
//  Created by Dmitry Kh on 19.10.22.
//

import XCTest
import Combine
@testable import TestTask

class ImageViewModelTests: XCTestCase {
  let mockRequestModel = DataRequestModel(path: nil, fileName: "TestFileName")
  let mockData = Data(repeating: 0, count: 200)
  var mockFetchUseCase =  MockFetchDataUseCase()
  var progress = Progress()
  
  override func setUp() {
    progress = Progress()
    mockFetchUseCase = MockFetchDataUseCase()
  }
  
  func testImageViewModel_Initialization() throws {
    // Given
    mockFetchUseCase.dataProgressEntity = DataProgressEntity(data: nil, progress: progress)
    
    // When
    let imageViewModel = ImageViewModel(model: mockRequestModel, fetchDataUseCase: mockFetchUseCase)
    
    // Then
    let status = try imageViewModel.status.get()
    XCTAssertEqual(status, .initialized)
    XCTAssertEqual(imageViewModel.dataProgress.progress.fractionCompleted, progress.fractionCompleted)
    XCTAssertNil(imageViewModel.dataProgress.data)
    XCTAssertEqual(imageViewModel.title, "Download".localized + " TestFileName")
  }
  
  func testImageViewModel_Status_SuccessStates() throws {
    // Given
    mockFetchUseCase.dataProgressEntity = DataProgressEntity(data: mockData, progress: progress)
    let imageViewModel = ImageViewModel(model: mockRequestModel, fetchDataUseCase: mockFetchUseCase)
    var testResult: [Status] = []
    var isMainThread = false

    // When
    let expectation = expectation(description: "Waiting for result")
    let cancellable = imageViewModel.$status
      .sink { result in
        isMainThread = Thread.isMultiThreaded()
        if case let .success(status) = result {
          testResult.append(status)
          if status == .finished {
            expectation.fulfill()
          }
        }
      }

    imageViewModel.startLoading()

    wait(for: [expectation], timeout: 5)
    cancellable.cancel()

    // Then
    XCTAssertTrue(isMainThread)
    XCTAssertEqual(testResult.count, 3)
    XCTAssertEqual(testResult[0], .initialized)
    XCTAssertEqual(testResult[1], .loading)
    XCTAssertEqual(testResult[2], .finished)
  }

  func testImageViewModel_Status_Failed() throws {
    // Given
    mockFetchUseCase.error = MockError.testError
    let imageViewModel = ImageViewModel(model: mockRequestModel, fetchDataUseCase: mockFetchUseCase)
    var expectedError: Error?
    var isMainThread = false

    // When
    let expectation = expectation(description: "Waiting for result")
    let cancellable = imageViewModel.$status
      .sink { result in
        isMainThread = Thread.isMultiThreaded()
        if case let .failure(error) = result {
          expectedError = error
          expectation.fulfill()
        }
      }
    imageViewModel.startLoading()
    
    waitForExpectations(timeout: 5)
    cancellable.cancel()

    // Then
    XCTAssertEqual(expectedError as? MockError, .testError)
    XCTAssertTrue(isMainThread)
  }

  func testImageViewModel_DataProgress() throws {
    // Given
    progress.totalUnitCount = 200
    progress.completedUnitCount = 100
    mockFetchUseCase.dataProgressEntity = DataProgressEntity(data: mockData, progress: progress)
    let imageViewModel = ImageViewModel(model: mockRequestModel, fetchDataUseCase: mockFetchUseCase)
    
    var isMainThread = false
    var expectedDataProgress: DataProgressEntity?

    // When
    let expectation = expectation(description: "Waiting for progress data result")
    let cancellable = imageViewModel.$dataProgress
      .sink { dataProgress in
        isMainThread = Thread.isMultiThreaded()
        expectedDataProgress = dataProgress
        if dataProgress.data != nil {
          expectation.fulfill()
        }
      }

    imageViewModel.startLoading()
    
    waitForExpectations(timeout: 5)
    cancellable.cancel()

    // Then
    XCTAssertTrue(isMainThread)
    XCTAssertEqual(expectedDataProgress?.data, mockData)
    XCTAssertEqual(expectedDataProgress?.progress.fractionCompleted, progress.fractionCompleted)
  }
}
