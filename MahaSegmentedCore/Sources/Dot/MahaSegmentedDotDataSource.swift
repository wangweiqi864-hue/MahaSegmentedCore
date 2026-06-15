//
//  MahaSegmentedDotDataSource.swift
//  MahaSegmentedView
//
//  Created by jiaxin on 2018/12/28.
//  Copyright © 2018 jiaxin. All rights reserved.
//

import UIKit

open class MahaSegmentedDotDataSource: MahaSegmentedTitleDataSource {
    /// 数量需要和titles一致，控制红点是否显示
    open var dotStates = [Bool]()
    /// 红点的size
    open var dotSize = CGSize(width: 10, height: 10)
    /// 红点的圆角值，MahaSegmentedViewAutomaticDimension等于dotSize.height/2
    open var dotCornerRadius: CGFloat = MahaSegmentedViewAutomaticDimension
    /// 红点的颜色
    open var dotColor = UIColor.red
    /// dotView的默认位置是center在titleLabel的右上角，可以通过dotOffset控制X、Y轴的偏移
    open var dotOffset: CGPoint = CGPoint.zero

    open override func preferredItemModelInstance() -> MahaSegmentedBaseItemModel {
        return MahaSegmentedDotItemModel()
    }

    open override func preferredRefreshItemModel(_ itemModel: MahaSegmentedBaseItemModel, at index: Int, selectedIndex: Int) {
        super.preferredRefreshItemModel(itemModel, at: index, selectedIndex: selectedIndex)

        guard let itemModel = itemModel as? MahaSegmentedDotItemModel else {
            return
        }

        itemModel.dotOffset = dotOffset
        itemModel.dotState = dotStates[index]
        itemModel.dotColor = dotColor
        itemModel.dotSize = dotSize
        if dotCornerRadius == MahaSegmentedViewAutomaticDimension {
            itemModel.dotCornerRadius = dotSize.height/2
        }else {
            itemModel.dotCornerRadius = dotCornerRadius
        }
    }

    //MARK: - MahaSegmentedViewDataSource
    open override func registerCellClass(in segmentedView: MahaSegmentedView) {
        segmentedView.collectionView.register(MahaSegmentedDotCell.self, forCellWithReuseIdentifier: "cell")
    }

    open override func segmentedView(_ segmentedView: MahaSegmentedView, cellForItemAt index: Int) -> MahaSegmentedBaseCell {
        let cell = segmentedView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        return cell
    }
}
