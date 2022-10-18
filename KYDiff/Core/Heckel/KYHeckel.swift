//
//  KYHeckel.swift
//  KYHeckelDiff
//
//  Created by keyon on 2022/10/18.
//

import UIKit

final class KYHeckel<T: KYDiffAware> {

    enum Counter {
        case zero, one, many

        func increment() -> Counter {
            switch self {
            case .zero:
                return .one
            case .one:
                return .many
            case .many:
                return self
            }
        }
    }

    class TableEntry: Equatable {
        static func == (lhs: TableEntry, rhs: TableEntry) -> Bool {
            return lhs.oldCounter == rhs.oldCounter && lhs.newCounter == rhs.newCounter && lhs.indexsInOld == rhs.indexsInOld
        }

        var oldCounter: Counter = .zero
        var newCounter: Counter = .zero

        var indexsInOld: [Int] = []

    }

    enum ArrayEntry: Equatable {
        case tableEntry(TableEntry)

        case indexInOther(Int)

        static func == (lhs: ArrayEntry, rhs: ArrayEntry) -> Bool {
            switch (lhs, rhs) {
            case (.tableEntry(let l), .tableEntry(let r)):
                return l == r
            case (.indexInOther(let l), .indexInOther(let r)):
                return l == r
            default:
                return false
            }
        }
    }

    func diff(old: [T], new: [T]) -> [KYChange<T>] {
        var table: [T.DiffId: TableEntry] = [:]
        var oldArray = [ArrayEntry]()
        var newArray = [ArrayEntry]()

        perform1stPass(new: new, table: &table, newArray: &newArray)
        perform2ndPass(old: old, table: &table, oldArray: &oldArray)
        perform345Pass(newArray: &newArray, oldArray: &oldArray)
        return perform6thPass(new: new, old: old, newArray: newArray, oldArray: oldArray)
    }

    private func perform1stPass(new: [T], table: inout [T.DiffId: TableEntry], newArray: inout [ArrayEntry]) {
        new.forEach { item in
            let entry = table[item.diffId] ?? TableEntry()
            entry.newCounter = entry.newCounter.increment()
            newArray.append(.tableEntry(entry))
            table[item.diffId] = entry
        }
    }

    private func perform2ndPass(old: [T], table: inout [T.DiffId: TableEntry], oldArray: inout [ArrayEntry]) {
        old.enumerated().forEach { tuple in
            let entry = table[tuple.element.diffId] ?? TableEntry()
            entry.oldCounter = entry.oldCounter.increment()
            entry.indexsInOld.append(tuple.offset)
            oldArray.append(.tableEntry(entry))
            table[tuple.element.diffId] = entry
        }
    }

    private func perform345Pass(newArray: inout [ArrayEntry], oldArray: inout [ArrayEntry]) {
        newArray.enumerated().forEach { (indexOfNew, item) in
            switch item {
            case .tableEntry(let entry):
                guard !entry.indexsInOld.isEmpty else { return }
                let indexOfOld = entry.indexsInOld.removeFirst()
                let isObservation1 = entry.newCounter == .one && entry.oldCounter == .one
                let isObservation2 = entry.newCounter != .zero && entry.oldCounter != .zero && newArray[indexOfNew] == oldArray[indexOfOld]
                guard isObservation1 || isObservation2 else { return }
                newArray[indexOfNew] = .indexInOther(indexOfOld)
                oldArray[indexOfOld] = .indexInOther(indexOfNew)
            case .indexInOther(_):
                break
            }
        }
    }

    private func perform6thPass(new: [T], old: [T], newArray: [ArrayEntry], oldArray: [ArrayEntry]) -> [KYChange<T>] {
        var changes = [KYChange<T>]()
        var deleteOffsets = Array(repeating: 0, count: old.count)
        do {
            var runningOffset = 0
            oldArray.enumerated().forEach { oldTuple in
                deleteOffsets[oldTuple.offset] = runningOffset
                guard case .tableEntry = oldTuple.element else { return }
                changes.append(.delete(KYDelete(item: old[oldTuple.offset], index: oldTuple.offset)))
                runningOffset += 1
            }
        }

        do {
            var runningOffset = 0
            newArray.enumerated().forEach { newTuple in
                switch newTuple.element {
                case .tableEntry:
                    runningOffset += 1
                    changes.append(.insert(KYInsert(item: new[newTuple.offset], index: newTuple.offset)))
                case .indexInOther(let oldIndex):
                    if !isEqual(oldItem: old[oldIndex], newItem: new[newTuple.offset]) {
                        changes.append(.replace(KYReplace(oldItem: old[oldIndex], newItem: new[newTuple.offset], index: newTuple.offset)))
                    }

                    let deleteOffset = deleteOffsets[oldIndex]
                    if (oldIndex - deleteOffset + runningOffset) != newTuple.offset {
                        changes.append(.move(KYMove(item: new[newTuple.offset], fromIndex: oldIndex, toIndex: newTuple.offset)))
                    }
                }
            }
        }
        return changes
    }

    func isEqual(oldItem: T, newItem: T) -> Bool {
      return T.compareContent(oldItem, newItem)
    }
}
