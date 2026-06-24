//
//  MahaSegmentedTitleGradientDataSource.swift
//  MahaSegmentedView
//
//  Created by jiaxin on 2019/1/23.
//  Copyright © 2019 jiaxin. All rights reserved.
//

import UIKit

open class MahaSegmentedTitleGradientDataSource: MahaSegmentedTitleDataSource {
    /// title普通状态下的渐变colors
    open var titleNormalGradientColors: [CGColor] = [UIColor.black.cgColor, UIColor.black.cgColor, UIColor.black.cgColor]
    /// title选中状态下的渐变colors
    open var titleSelectedGradientColors: [CGColor] = [UIColor(red: 18/255.0, green: 194/255.0, blue: 233/255.0, alpha: 1).cgColor, UIColor(red: 196/255.0, green: 113/255.0, blue: 237/255.0, alpha: 1).cgColor, UIColor(red: 246/255.0, green: 79/255.0, blue: 89/255.0, alpha: 1).cgColor]
    /// title渐变的StartPoint
    open var titleGradientStartPoint: CGPoint = CGPoint(x: 0, y: 0)
    /// title渐变的EndPoint
    open var titleGradientEndPoint: CGPoint = CGPoint(x: 1, y: 0)

    open override func preferredItemModelInstance() -> MahaSegmentedBaseItemModel {
        return MahaSegmentedTitleGradientItemModel()
    }

    open override func preferredRefreshItemModel(_ itemModel: MahaSegmentedBaseItemModel, at index: Int, selectedIndex: Int) {
        super.preferredRefreshItemModel(itemModel, at: index, selectedIndex: selectedIndex)

        guard let gradientItemModel = itemModel as? MahaSegmentedTitleGradientItemModel else {
            return
        }

        configureGradientItemModel(gradientItemModel)
        gradientItemModel.titleCurrentGradientColors = index == selectedIndex ? gradientItemModel.titleSelectedGradientColors : gradientItemModel.titleNormalGradientColors
    }

    //MARK: - MahaSegmentedViewDataSource
    open override func registerCellClass(in segmentedView: MahaSegmentedView) {
        segmentedView.collectionView.register(MahaSegmentedTitleGradientCell.self, forCellWithReuseIdentifier: "cell")
    }

    open override func segmentedView(_ segmentedView: MahaSegmentedView, cellForItemAt index: Int) -> MahaSegmentedBaseCell {
        return segmentedView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
    }

    open override func refreshItemModel(_ segmentedView: MahaSegmentedView, leftItemModel: MahaSegmentedBaseItemModel, rightItemModel: MahaSegmentedBaseItemModel, percent: CGFloat) {
        super.refreshItemModel(segmentedView, leftItemModel: leftItemModel, rightItemModel: rightItemModel, percent: percent)

        guard let leftModel = leftItemModel as? MahaSegmentedTitleGradientItemModel, let rightModel = rightItemModel as? MahaSegmentedTitleGradientItemModel else {
            return
        }

        if isTitleColorGradientEnabled && isItemTransitionEnabled {
            leftModel.titleCurrentGradientColors = MahaSegmentedViewTool.interpolateColors(from: leftModel.titleSelectedGradientColors, to: leftModel.titleNormalGradientColors, percent: percent)
            rightModel.titleCurrentGradientColors = MahaSegmentedViewTool.interpolateColors(from: rightModel.titleNormalGradientColors, to: rightModel.titleSelectedGradientColors, percent: percent)
        }
    }

    open override func refreshItemModel(_ segmentedView: MahaSegmentedView, currentSelectedItemModel: MahaSegmentedBaseItemModel, willSelectedItemModel: MahaSegmentedBaseItemModel, selectedType: MahaSegmentedViewItemSelectedType) {
        super.refreshItemModel(segmentedView, currentSelectedItemModel: currentSelectedItemModel, willSelectedItemModel: willSelectedItemModel, selectedType: selectedType)

        guard let currentGradientItemModel = currentSelectedItemModel as? MahaSegmentedTitleGradientItemModel,
              let nextGradientItemModel = willSelectedItemModel as? MahaSegmentedTitleGradientItemModel else {
            return
        }

        currentGradientItemModel.titleCurrentGradientColors = currentGradientItemModel.titleNormalGradientColors
        nextGradientItemModel.titleCurrentGradientColors = nextGradientItemModel.titleSelectedGradientColors
    }

    private func configureGradientItemModel(_ itemModel: MahaSegmentedTitleGradientItemModel) {
        itemModel.titleGradientStartPoint = titleGradientStartPoint
        itemModel.titleGradientEndPoint = titleGradientEndPoint
        itemModel.titleNormalGradientColors = titleNormalGradientColors
        itemModel.titleSelectedGradientColors = titleSelectedGradientColors
    }
}
