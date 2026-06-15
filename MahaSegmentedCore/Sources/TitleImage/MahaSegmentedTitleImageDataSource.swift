//
//  MahaSegmentedTitleImageDataSource.swift
//  MahaSegmentedView
//
//  Created by jiaxin on 2018/12/29.
//  Copyright © 2018 jiaxin. All rights reserved.
//

import UIKit

public enum MahaSegmentedTitleImageType {
    case topImage
    case leftImage
    case bottomImage
    case rightImage
    case onlyImage
    case onlyTitle
}

public typealias MahaSegmentedLoadImageClosure = ((UIImageView, String) -> Void)

open class MahaSegmentedTitleImageDataSource: MahaSegmentedTitleDataSource {
    open var titleImageType: MahaSegmentedTitleImageType = .rightImage
    /// 数量需要和item的数量保持一致。可以是ImageName或者图片网络地址
    open var normalImageInfos: [String]?
    /// 数量需要和item的数量保持一致。可以是ImageName或者图片网络地址。如果不赋值，选中时就不会处理图片切换。
    open var selectedImageInfos: [String]?
    /// 内部默认通过UIImage(named:)加载图片。如果传递的是图片网络地址或者想自己处理图片加载逻辑，可以通过该闭包处理。
    open var loadImageClosure: MahaSegmentedLoadImageClosure?
    /// 图片尺寸
    open var imageSize: CGSize = CGSize(width: 20, height: 20)
    /// title和image之间的间隔
    open var titleImageSpacing: CGFloat = 5
    /// 是否开启图片缩放
    open var isImageZoomEnabled: Bool = false
    /// 图片缩放选中时的scale
    open var imageSelectedZoomScale: CGFloat = 1.2

    open override func preferredItemModelInstance() -> MahaSegmentedBaseItemModel {
        return MahaSegmentedTitleImageItemModel()
    }

    open override func preferredRefreshItemModel(_ itemModel: MahaSegmentedBaseItemModel, at index: Int, selectedIndex: Int) {
        super.preferredRefreshItemModel(itemModel, at: index, selectedIndex: selectedIndex)

        guard let itemModel = itemModel as? MahaSegmentedTitleImageItemModel else {
            return
        }

        itemModel.titleImageType = titleImageType
        itemModel.normalImageInfo = normalImageInfos?[index]
        itemModel.selectedImageInfo = selectedImageInfos?[index]
        itemModel.loadImageClosure = loadImageClosure
        itemModel.imageSize = imageSize
        itemModel.isImageZoomEnabled = isImageZoomEnabled
        itemModel.imageNormalZoomScale = 1
        itemModel.imageSelectedZoomScale = imageSelectedZoomScale
        itemModel.titleImageSpacing = titleImageSpacing
        if index == selectedIndex {
            itemModel.imageCurrentZoomScale = itemModel.imageSelectedZoomScale
        }else {
            itemModel.imageCurrentZoomScale = itemModel.imageNormalZoomScale
        }
    }

    open override func preferredSegmentedView(_ segmentedView: MahaSegmentedView, widthForItemAt index: Int) -> CGFloat {
        var width = super.preferredSegmentedView(segmentedView, widthForItemAt: index)
        if itemWidth == MahaSegmentedViewAutomaticDimension {
            switch titleImageType {
            case .leftImage, .rightImage:
                width += titleImageSpacing + imageSize.width
            case .topImage, .bottomImage:
                width = max(itemWidth, imageSize.width)
            case .onlyImage:
                width = imageSize.width
            case .onlyTitle:
                break
            }
        }
        return width
    }

    public override func segmentedView(_ segmentedView: MahaSegmentedView, widthForItemContentAt index: Int) -> CGFloat {
        var width = super.segmentedView(segmentedView, widthForItemContentAt: index)
        switch titleImageType {
        case .leftImage, .rightImage:
            width += titleImageSpacing + imageSize.width
        case .topImage, .bottomImage:
            width = max(itemWidth, imageSize.width)
        case .onlyImage:
            width = imageSize.width
        case .onlyTitle:
            break
        }
        return width
    }

    //MARK: - MahaSegmentedViewDataSource
    open override func registerCellClass(in segmentedView: MahaSegmentedView) {
        segmentedView.collectionView.register(MahaSegmentedTitleImageCell.self, forCellWithReuseIdentifier: "cell")
    }

    open override func segmentedView(_ segmentedView: MahaSegmentedView, cellForItemAt index: Int) -> MahaSegmentedBaseCell {
        let cell = segmentedView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        return cell
    }

    open override func refreshItemModel(_ segmentedView: MahaSegmentedView, leftItemModel: MahaSegmentedBaseItemModel, rightItemModel: MahaSegmentedBaseItemModel, percent: CGFloat) {
        super.refreshItemModel(segmentedView, leftItemModel: leftItemModel, rightItemModel: rightItemModel, percent: percent)

        guard let leftModel = leftItemModel as? MahaSegmentedTitleImageItemModel, let rightModel = rightItemModel as? MahaSegmentedTitleImageItemModel else {
            return
        }
        if isImageZoomEnabled && isItemTransitionEnabled {
            leftModel.imageCurrentZoomScale = MahaSegmentedViewTool.interpolate(from: imageSelectedZoomScale, to: 1, percent: CGFloat(percent))
            rightModel.imageCurrentZoomScale = MahaSegmentedViewTool.interpolate(from: 1, to: imageSelectedZoomScale, percent: CGFloat(percent))
        }
    }

    open override func refreshItemModel(_ segmentedView: MahaSegmentedView, currentSelectedItemModel: MahaSegmentedBaseItemModel, willSelectedItemModel: MahaSegmentedBaseItemModel, selectedType: MahaSegmentedViewItemSelectedType) {
        super.refreshItemModel(segmentedView, currentSelectedItemModel: currentSelectedItemModel, willSelectedItemModel: willSelectedItemModel, selectedType: selectedType)

        guard let myCurrentSelectedItemModel = currentSelectedItemModel as? MahaSegmentedTitleImageItemModel, let myWillSelectedItemModel = willSelectedItemModel as? MahaSegmentedTitleImageItemModel else {
            return
        }

        myCurrentSelectedItemModel.imageCurrentZoomScale = myCurrentSelectedItemModel.imageNormalZoomScale
        myWillSelectedItemModel.imageCurrentZoomScale = myWillSelectedItemModel.imageSelectedZoomScale
    }
}
