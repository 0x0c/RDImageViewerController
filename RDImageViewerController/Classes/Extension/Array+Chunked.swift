//
//  Array+Chunked.swift
//  RDImageViewerController
//
//  Created by Akira Matsuda on 2020/11/02.
//

import Foundation

extension Array {
    func rd_chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
