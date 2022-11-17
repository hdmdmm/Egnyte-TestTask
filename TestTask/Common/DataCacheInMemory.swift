//
//  DataCache.swift
//  TestTask
//
//  Created by Dmitry Kh on 11.10.22.
//

import Foundation

protocol DataCacheProtocol {
  subscript(_ url: URL) -> Data? { get set }
}

struct DataCacheInMemory: DataCacheProtocol {
  private let cache: NSCache<NSURL, NSData>
  init(_ cache: NSCache<NSURL, NSData>? = nil) {
    if let cache = cache {
      self.cache = cache
      return
    }
    self.cache = NSCache<NSURL, NSData>()
    self.cache.name = ""
  }

  subscript(_ key: URL) -> Data? {
    get { cache.object(forKey: key as NSURL) as Data? }
    set {
      if let object = newValue {
        cache.setObject(object as NSData, forKey: key as NSURL)
        return
      }
      cache.removeObject(forKey: key as NSURL)
    }
  }
}
