//
//  Model.swift
//  TestTask
//
//  Created by Dmitry Kh on 12.10.22.
//

import Foundation

struct DataRequestModel {
  let path: String?
  let fileName: String
  
  var fullPath: String {
    "\(path ?? "")/\(fileName)"
  }
}
