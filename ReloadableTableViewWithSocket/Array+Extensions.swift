//
//  Array+Extensions.swift
//  TableViewWithMultipleCellTypes
//
//  Created by Stan Ostrovskiy on 9/20/17.
//  Copyright © 2017 Stanislav Ostrovskiy. All rights reserved.
//

import Foundation

extension Array where Element: Hashable {
   
    /// Remove duplicates from the array, preserving the items order
    func filterDuplicates() -> Array<Element> {
        var set = Set<Element>()
        var filteredArray = Array<Element>()
        for item in self {
            if set.insert(item).inserted {
                filteredArray.append(item)
            }
        }
        return filteredArray
    }
}
