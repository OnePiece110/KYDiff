//
//  KYHeckelDiff.swift
//  KYHeckelDiff
//
//  Created by keyon on 2022/10/18.
//

import Foundation

func diff<T: KYDiffAware>(old: [T], new: [T]) -> [KYChange<T>] {
  let heckel = KYHeckel<T>()
  return heckel.diff(old: old, new: new)
}
