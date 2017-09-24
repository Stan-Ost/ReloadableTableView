//
//  DiffCalculator.swift
//  TableViewWithMultipleCellTypes
//
//  Created by Stan Ostrovskiy on 9/20/17.
//  Copyright © 2017 Stanislav Ostrovskiy. All rights reserved.
//

import Foundation

class SectionChanges {
    var insertsInts = [Int]()
    var deletesInts = [Int]()
    var updates = CellChanges()
    
    var inserts: IndexSet {
        return IndexSet(insertsInts)
    }
    var deletes: IndexSet {
        return IndexSet(deletesInts)
    }
    
    init(inserts: [Int] = [], deletes: [Int] = [], updates: CellChanges = CellChanges()) {
        self.insertsInts = inserts
        self.deletesInts = deletes
        self.updates = updates
    }
}

class CellChanges {
    var inserts = [IndexPath]()
    var deletes = [IndexPath]()
    var reloads = [IndexPath]()
    
    init(inserts: [IndexPath] = [], deletes: [IndexPath] = [], reloads: [IndexPath] = []) {
        self.inserts = inserts
        self.deletes = deletes
        self.reloads = reloads
    }
}

struct ReloadableSection<N: Equatable>: Equatable {
    var key: String
    var value: [ReloadableCell<N>]
    var index: Int
    
    static func ==(lhs: ReloadableSection, rhs: ReloadableSection) -> Bool {
        return lhs.key == rhs.key && lhs.value == rhs.value
    }
}

struct ReloadableCell<N:Equatable>: Equatable {
    var key: String
    var value: N
    var index: Int
    
    static func ==(lhs: ReloadableCell, rhs: ReloadableCell) -> Bool {
        return lhs.key == rhs.key && lhs.value == rhs.value
    }
}

struct ReloadableSectionData<N: Equatable> {
    var items = [ReloadableSection<N>]()
    
    subscript(key: String) -> ReloadableSection<N>? {
        get {
            return items.filter { $0.key == key }.first
        }
    }
    
    subscript(index: Int) -> ReloadableSection<N>? {
        get {
            return items.filter { $0.index == index }.first
        }
    }
}

struct ReloadableCellData<N: Equatable> {
    var items = [ReloadableCell<N>]()
    
    subscript(key: String) -> ReloadableCell<N>? {
        get {
            return items.filter { $0.key == key }.first
        }
    }
    
    subscript(index: Int) -> ReloadableCell<N>? {
        get {
            return items.filter { $0.index == index }.first
        }
    }
}

class DiffCalculator {
    static func calculate<N>(oldItems: [ReloadableSection<N>], newItems: [ReloadableSection<N>]) -> SectionChanges {
        let sectionChanges = SectionChanges()
        let uniqueSectionKeys = (oldItems + newItems)
            .map { $0.key }
            .filterDuplicates()
        
        let cellChanges = CellChanges()
        
        for sectionKey in uniqueSectionKeys {
            let oldSectionItem = ReloadableSectionData(items: oldItems)[sectionKey]
            let newSectionItem = ReloadableSectionData(items: newItems)[sectionKey]
            if let oldSectionItem = oldSectionItem, let newSectionItem = newSectionItem {
                if oldSectionItem != newSectionItem {
                    let oldCellIData = ReloadableCellData(items: oldSectionItem.value)
                    let newCellData = ReloadableCellData(items: newSectionItem.value)
                    
                    let uniqueCellKeys = (oldCellIData.items + newCellData.items)
                        .map { $0.key }
                        .filterDuplicates()
                    
                    for cellKey in uniqueCellKeys {
                        let oldCellItem = oldCellIData[cellKey]
                        let newCellItem = newCellData[cellKey]
                        if let oldCellItem = oldCellItem, let newCelItem = newCellItem {
                            if oldCellItem != newCelItem {
                                cellChanges.reloads.append(IndexPath(row: oldCellItem.index, section: oldSectionItem.index))
                            }
                        } else if let oldCellItem = oldCellItem {
                            cellChanges.deletes.append(IndexPath(row: oldCellItem.index, section: oldSectionItem.index))
                        } else if let newCellItem = newCellItem {
                            cellChanges.inserts.append(IndexPath(row: newCellItem.index, section: newSectionItem.index))
                        }
                    }
                }
            } else if let oldSectionItem = oldSectionItem {
                sectionChanges.deletesInts.append(oldSectionItem.index)
            } else if let newSectionItem = newSectionItem {
                sectionChanges.insertsInts.append(newSectionItem.index)
            }
        }
        
        sectionChanges.updates = cellChanges
        
        return sectionChanges
    }
}
