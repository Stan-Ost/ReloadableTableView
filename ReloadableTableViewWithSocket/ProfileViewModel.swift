//
//  ProfileViewModel.swift
//  TableViewWithMultipleCellTypes
//
//  Created by Stanislav Ostrovskiy on 4/25/17.
//  Copyright © 2017 Stanislav Ostrovskiy. All rights reserved.
//

import Foundation
import UIKit

enum ProfileViewModelItemType: String {
    case nameAndPicture = "nameAndPicture"
    case about = "about"
    case email = "email"
    case friend = "friend"
    case attribute = "attribute"
}

protocol ProfileViewModelItem {
    var type: ProfileViewModelItemType { get }
    var sectionTitle: String { get }
    var cellItems: [CellItem] { get}
}

struct CellItem: Equatable {
    var value: CustomStringConvertible
    var id: String

    static func ==(lhs: CellItem, rhs: CellItem) -> Bool {
        return lhs.id == rhs.id && lhs.value.description == rhs.value.description
    }
}

protocol ProfileViewModelDelegate: class {
    func apply(changes: SectionChanges)
}

class ProfileViewModel: NSObject {
    fileprivate var items = [ProfileViewModelItem]()
    
    weak var delegate: ProfileViewModelDelegate?
    
    private func flatten(items: [ProfileViewModelItem]) -> [ReloadableSection<CellItem>] {
        let reloadableItems = items
            .enumerated()
            .map { ReloadableSection(key: $0.element.type.rawValue, value: $0.element.cellItems
                .enumerated()
                .map { ReloadableCell(key: $0.element.id, value: $0.element, index: $0.offset)  }, index: $0.offset) }
        return reloadableItems
    }

    private func setup(newItems: [ProfileViewModelItem]) {
        let oldData = flatten(items: items)
        let newData = flatten(items: newItems)
        let sectionChanges = DiffCalculator.calculate(oldItems: oldData, newItems: newData)

        items = newItems
        delegate?.apply(changes: sectionChanges)
    }

    func addListener() {
        NetworkManager.shared.loadData { [weak self] profile in
            self?.parseData(profile: profile)
        }
    }
    
    private func parseData(profile: Profile) {
        var newItems = [ProfileViewModelItem]()
        if let name = profile.fullName, let pictureUrl = profile.pictureUrl {
            let nameAndPictureItem = ProfileViewModelNamePictureItem(name: name, pictureUrl: pictureUrl)
            newItems.append(nameAndPictureItem)
        }
        
        if let about = profile.about {
            let aboutItem = ProfileViewModelAboutItem(about: about)
            newItems.append(aboutItem)
        }
        
        if let email = profile.email {
            let dobItem = ProfileViewModelEmailItem(email: email)
            newItems.append(dobItem)
        }
        
        let attributes = profile.profileAttributes
        if !attributes.isEmpty {
            let attributesItem = ProfileViewModeAttributeItem(attributes: attributes)
            newItems.append(attributesItem)
        }
        
        let friends = profile.friends
        if !profile.friends.isEmpty {
            let friendsItem = ProfileViewModeFriendsItem(friends: friends)
            newItems.append(friendsItem)
        }
        
        setup(newItems: newItems)
    }
}

extension ProfileViewModel: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items[section].cellItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.section]
        switch item.type {
        case .nameAndPicture:
            if let cell = tableView.dequeueReusableCell(withIdentifier: NamePictureCell.identifier, for: indexPath) as? NamePictureCell {
                cell.item = item
                return cell
            }
        case .about:
            if let cell = tableView.dequeueReusableCell(withIdentifier: AboutCell.identifier, for: indexPath) as? AboutCell {
                cell.item = item
                return cell
            }
        case .email:
            if let cell = tableView.dequeueReusableCell(withIdentifier: EmailCell.identifier, for: indexPath) as? EmailCell {
                cell.item = item
                return cell
            }
        case .friend:
            if let item = item as? ProfileViewModeFriendsItem, let cell = tableView.dequeueReusableCell(withIdentifier: FriendCell.identifier, for: indexPath) as? FriendCell {
                let friend = item.friends[indexPath.row]
                cell.item = friend
                return cell
            }
        case .attribute:
            if let item = item as? ProfileViewModeAttributeItem, let cell = tableView.dequeueReusableCell(withIdentifier: AttributeCell.identifier, for: indexPath) as? AttributeCell {
                cell.item = item.attributes[indexPath.row]
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return items[section].sectionTitle
    }
}

class ProfileViewModelNamePictureItem: ProfileViewModelItem {
    var type: ProfileViewModelItemType {
        return .nameAndPicture
    }
    
    var sectionTitle: String {
        return "Main Info"
    }
    
    
    var cellItems: [CellItem] {
        return [CellItem(value: "\(pictureUrl), \(name)", id: sectionTitle)]
    }
    
    var name: String
    var pictureUrl: String
    
    init(name: String, pictureUrl: String) {
        self.name = name
        self.pictureUrl = pictureUrl
    }
}

class ProfileViewModelAboutItem: ProfileViewModelItem {
    var type: ProfileViewModelItemType {
        return .about
    }
    
    var sectionTitle: String {
        return "About"
    }
    
    var cellItems: [CellItem] {
        return [CellItem(value: about, id: sectionTitle)]
    }
    
    var about: String
    
    init(about: String) {
        self.about = about
    }
}

class ProfileViewModelEmailItem: ProfileViewModelItem {
    var type: ProfileViewModelItemType {
        return .email
    }
    
    var sectionTitle: String {
        return "Email"
    }
    
    var cellItems: [CellItem] {
        return [CellItem(value: email, id: sectionTitle)]
    }
    
    var email: String
    
    init(email: String) {
        self.email = email
    }
}

class ProfileViewModeAttributeItem: ProfileViewModelItem {
    var type: ProfileViewModelItemType {
        return .attribute
    }
    
    var sectionTitle: String {
        return "Attributes"
    }
    
    var cellItems: [CellItem] {
        return attributes
            .map { CellItem(value: $0, id: $0.key) }
    }
    
    var attributes: [Attribute]
    
    init(attributes: [Attribute]) {
        self.attributes = attributes
    }
}

class ProfileViewModeFriendsItem: ProfileViewModelItem {
    var type: ProfileViewModelItemType {
        return .friend
    }
    
    var sectionTitle: String {
        return "Friends"
    }
    
    var cellItems: [CellItem] {
        return friends
            .map { CellItem(value: $0, id: $0.name) }
    }
    
    var friends: [Friend]
    
    init(friends: [Friend]) {
        self.friends = friends
    }
}
