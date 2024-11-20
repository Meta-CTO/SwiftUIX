//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if (os(iOS) && canImport(CoreTelephony)) || os(tvOS) || targetEnvironment(macCatalyst)

extension CocoaList {
    public init<_Item: Hashable>(
        _ data: Data,
        sectionHeader: @escaping (SectionType) -> SectionHeader,
        sectionFooter: @escaping (SectionType) -> SectionFooter,
        rowContent: @escaping (_Item, IndexPath) -> RowContent
    ) where ItemType == _HashIdentifiableValue<_Item> {
        self.data = data
        self.sectionHeader = sectionHeader
        self.sectionFooter = sectionFooter
        self.rowContent = { rowContent($0.value, $1) }
    }
    
    public init<_SectionType: Hashable, _Item: Hashable>(
        _ data: Data,
        sectionHeader: @escaping (_SectionType) -> SectionHeader,
        sectionFooter: @escaping (_SectionType) -> SectionFooter,
        rowContent: @escaping (_Item, IndexPath) -> RowContent
    ) where SectionType == _HashIdentifiableValue<_SectionType>, ItemType == _HashIdentifiableValue<_Item> {
        self.data = data
        self.sectionHeader = { sectionHeader($0.value) }
        self.sectionFooter = { sectionFooter($0.value) }
        self.rowContent = { rowContent($0.value, $1) }
    }
    
    public init<_SectionType: Hashable, _Item: Hashable>(
        _ data: [ListSection<_SectionType, _Item>],
        sectionHeader: @escaping (_SectionType) -> SectionHeader,
        sectionFooter: @escaping (_SectionType) -> SectionFooter,
        rowContent: @escaping (_Item, IndexPath) -> RowContent
    ) where Data == Array<ListSection<SectionType, ItemType>>, SectionType == _HashIdentifiableValue<_SectionType>, ItemType == _HashIdentifiableValue<_Item> {
        self.data = data.map({ .init(model: .init($0.model), items: $0.items.map(_HashIdentifiableValue.init)) })
        self.sectionHeader = { sectionHeader($0.value) }
        self.sectionFooter = { sectionFooter($0.value) }
        self.rowContent = { rowContent($0.value, $1) }
    }
}

extension CocoaList where SectionType == _KeyPathHashIdentifiableValue<Int, Int>, SectionHeader == Never, SectionFooter == Never {
    public init<
        _ItemType,
        _ItemID,
        Items: RandomAccessCollection
    >(
        _ items: Items,
        id: KeyPath<_ItemType, _ItemID>,
        @ViewBuilder rowContent: @escaping (_ItemType, IndexPath) -> RowContent
    ) where Data == AnyRandomAccessCollection<ListSection<SectionType, ItemType>>, Items.Element == _ItemType, ItemType == _KeyPathHashIdentifiableValue<_ItemType, _ItemID> {
        self.init(
            AnyRandomAccessCollection([ListSection(_KeyPathHashIdentifiableValue(value: 0, keyPath: \.self), items: items.elements(identifiedBy: id))]),
            sectionHeader: Never._SwiftUIX_produce,
            sectionFooter: Never._SwiftUIX_produce,
            rowContent: { rowContent($0.value, $1) }
        )
    }
}

extension CocoaList where Data: RangeReplaceableCollection, SectionType == _KeyPathHashIdentifiableValue<Int, Int>, SectionHeader == Never, SectionFooter == Never {
    public init<Items: RandomAccessCollection>(
        _ items: Items,
        @ViewBuilder rowContent: @escaping (ItemType, IndexPath) -> RowContent
    ) where Items.Element == ItemType {
        var data = Data()
        
        data.append(ListSection(_KeyPathHashIdentifiableValue(value: 0, keyPath: \.self), items: items))
        
        self.init(
            data,
            sectionHeader: Never._SwiftUIX_produce,
            sectionFooter: Never._SwiftUIX_produce,
            rowContent: rowContent
        )
    }
}

extension CocoaList where Data == Array<ListSection<SectionType, ItemType>>, SectionType == _KeyPathHashIdentifiableValue<Int, Int>, SectionHeader == Never, SectionFooter == Never
{
    public init<Items: RandomAccessCollection>(
        _ items: Items,
        @ViewBuilder rowContent: @escaping (ItemType, IndexPath) -> RowContent
    ) where Items.Element == ItemType {
        self.init(
            [.init(_KeyPathHashIdentifiableValue(value: 0, keyPath: \.self), items: items)],
            sectionHeader: Never._SwiftUIX_produce,
            sectionFooter: Never._SwiftUIX_produce,
            rowContent: rowContent
        )
    }
}

#endif
