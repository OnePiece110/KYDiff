
struct KYMyersScript<T> {
    enum Action {
        case delete(at: Int)
        case insert(at: Int)
        case same(old: Int, new: Int)
    }

    var action: Action
    var value: T
}

struct KYMyersV {
    private var store: [String: Int]

    init() {
        self.store = [String: Int]()
    }

    subscript(_ index: Int) -> Int {
        get {
            store["\(index)"] ?? 0
        }
        set {
            store["\(index)"] = newValue
        }
    }
}

struct KYMyers<T: Hashable> {

    static func diff(old: [T], new: [T]) -> [KYMyersScript<T>] {
        let maxX = old.count
        let maxY = new.count
        let max = maxX + maxY
        var vertices = KYMyersV()
        var trace = [KYMyersV]()
        var x = 0
        var y = 0
        for d in 0...max {
            let preV = vertices
            trace.append(preV)
            vertices = KYMyersV()
            for k in stride(from: -d, through: d, by: 2) {
                if k == -d || (k != d && preV[k - 1] < preV[k + 1]) {
                    x = preV[k + 1]
                } else {
                    x = preV[k - 1] + 1
                }
                y = x - k
                while x < maxX, y < maxY, old[x] == new[y] {
                    x += 1
                    y += 1
                }
                vertices[k] = x
                if x >= maxX, y >= maxY {
                    return backtrace(old: old, new: new, trace: trace)
                }
            }
            if x >= maxX, y >= maxY {
                break
            }
        }
        return backtrace(old: old, new: new, trace: trace)
    }

    private static func backtrace(old: [T], new: [T], trace: [KYMyersV]) -> [KYMyersScript<T>] {
        var (x, y) = (old.count, new.count)
        var path = [KYMyersScript<T>]()
        for (d, vertices) in trace.enumerated().reversed() {
            let k = x - y
            let preK: Int
            if k == -d || (k != d && vertices[k-1] < vertices[k+1]) {
                preK = k + 1
            } else {
                preK = k - 1
            }
            let preX = vertices[preK]
            let preY = preX - preK
            while x > preX, y > preY {
                path.append(.init(action: .same(old: x, new: y), value: old[x - 1]))
                x -= 1
                y -= 1
            }
            if x == 0, y == 0 {
                return path.reversed()
            }
            if x == preX {
                path.append(.init(action: .insert(at: y), value: new[y - 1]))
            } else {
                path.append(.init(action: .delete(at: x), value: old[x - 1]))
            }
            (x, y) = (preX, preY)
        }
        return path.reversed()
    }
}
