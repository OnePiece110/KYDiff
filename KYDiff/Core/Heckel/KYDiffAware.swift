//
//  KYDiffAware.swift
//  KYHeckelDiff
//
//  Created by keyon on 2022/10/18.
//

import UIKit

protocol KYDiffAware {
    associatedtype DiffId: Hashable
    
    var diffId: DiffId { get }
    static func compareContent(_ a: Self, _ b: Self) -> Bool
}

extension KYDiffAware where Self: Hashable {
    var diffId: Self {
        return self
    }

    static func compareContent(_ a: Self, _ b: Self) -> Bool {
        return a == b
    }
}

extension Int: KYDiffAware {}
extension String: KYDiffAware {}
extension Character: KYDiffAware {}
extension UUID: KYDiffAware {}
