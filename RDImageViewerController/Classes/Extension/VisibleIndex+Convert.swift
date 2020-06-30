//
//  VisibleIndex+Convert.swift
//  Pods
//
//  Created by Akira Matsuda on 2020/07/01.
//

extension PagingView.VisibleIndex {
    public static func == (a: PagingView.VisibleIndex, b: PagingView.VisibleIndex) -> Bool {
        switch (a, b) {
        case let (.single(index1), .single(index2)):
            return index1 == index2
        case let (.double(indexes1), .double(indexes2)):
            return indexes1 == indexes2
        default:
            return false
        }
    }

    public static func != (a: PagingView.VisibleIndex, b: PagingView.VisibleIndex) -> Bool {
        switch (a, b) {
        case let (.single(index1), .single(index2)):
            return !(index1 == index2)
        case let (.double(indexes1), .double(indexes2)):
            return !(indexes1 == indexes2)
        default:
            return true
        }
    }

    public func contains(_ index: PagingView.VisibleIndex) -> Bool {
        switch (self, index) {
        case let (.single(index1), .single(index2)):
            return (index1 == index2)
        case let (.single(index1), .double(index2)):
            if index2.count == 1, let index = index2.first {
                return index1 == index
            }
            return false
        case let (.double(index1), .single(index2)):
            return index1.contains(index2)
        case let (.double(indexes1), .double(indexes2)):
            var result = true
            for i in indexes2 {
                result = result && indexes1.contains(i)
            }
            return result
        }
    }

    public func convert(double: Bool) -> PagingView.VisibleIndex {
        switch self {
        case let .single(index):
            if double {
                return .double(indexes: [index])
            }
            return self
        case let .double(indexes):
            if double {
                return self
            }

            if let index = indexes.sorted().first {
                return .single(index: index)
            }
            return .single(index: 0)
        }
    }

    public func primaryIndex() -> Int {
        switch self {
        case let .single(index):
            return index
        case let .double(indexes):
            if let index = indexes.sorted().first {
                return index
            }
            return -1
        }
    }
}
