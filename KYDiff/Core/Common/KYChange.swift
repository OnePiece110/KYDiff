//
//  KYChange.swift
//  KYHeckelDiff
//
//  Created by keyon on 2022/10/18.
//

import UIKit

struct KYInsert<T> {
    let item: T
    let index: Int
}

struct KYDelete<T> {
    let item: T
    let index: Int
}

struct KYReplace<T> {
    let oldItem: T
    let newItem: T
    let index: Int
}

struct KYMove<T> {
    let item: T
    let fromIndex: Int
    let toIndex: Int
}

enum KYChange<T> {
    case insert(KYInsert<T>)
    case delete(KYDelete<T>)
    case replace(KYReplace<T>)
    case move(KYMove<T>)

    var insert: KYInsert<T>? {
        if case .insert(let insert) = self {
            return insert
        }
        return nil
    }

    var delete: KYDelete<T>? {
        if case .delete(let delete) = self {
            return delete
        }
        return nil
    }

    var replace: KYReplace<T>? {
        if case .replace(let replace) = self {
            return replace
        }
        return nil
    }

    var move: KYMove<T>? {
        if case .move(let move) = self {
            return move
        }
        return nil
    }
}
