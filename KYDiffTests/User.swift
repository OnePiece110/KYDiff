//
//  User.swift
//  KYHeckelDiffTests
//
//  Created by keyon on 2022/10/18.
//

import Foundation

struct User: Equatable {
  let id: Int
  let name: String
}

extension User: KYDiffAware {
  var diffId: Int {
    return id
  }

  static func compareContent(_ a: User, _ b: User) -> Bool {
    return a.name == b.name
  }
}
