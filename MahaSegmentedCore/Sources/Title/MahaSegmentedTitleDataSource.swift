//
//  MahaSegmentedTitleView.swift
//  MahaSegmentedView
//
//  Created by jiaxin on 2018/12/26.
//  Copyright © 2018 jiaxin. All rights reserved.
//

import UIKit

open class MahaSegmentedTitleDataSource: MahaSegmentedBaseDataSource {
    /// title数组
    open var titles = [String]()
    /// 根据index配置cell的不同属性
    open weak var configuration: MahaSegmentedTitleDynamicConfiguration?
    /// 如果将MahaSegmentedView嵌套进UITableView的cell，每次重用的时候，MahaSegmentedView进行reloadData时，会重新计算所有的title宽度。所以该应用场景，需要UITableView的cellModel缓存titles的文字宽度，再通过该闭包方法返回给MahaSegmentedView。
    open var widthForTitleClosure: ((String)->(CGFloat))?
    /// label的numberOfLines
    open var titleNumberOfLines: Int = 1
    /// title普通状态的textColor
    open var titleNormalColor: UIColor = .black
    /// title选中状态的textColor
    open var titleSelectedColor: UIColor = .red
    /// title普通状态时的字体
    open var titleNormalFont: UIFont = UIFont.systemFont(ofSize: 15)
    /// title选中时的字体。如果不赋值，就默认与titleNormalFont一样
    open var titleSelectedFont: UIFont?
    /// title的颜色是否渐变过渡
    open var isTitleColorGradientEnabled: Bool = false
    /// title是否缩放。使用该效果时，务必保证titleNormalFont和titleSelectedFont值相同。
    open var isTitleZoomEnabled: Bool = false
    /// isTitleZoomEnabled为true才生效。是对字号的缩放，比如titleNormalFont的pointSize为10，放大之后字号就是10*1.2=12。
    open var titleSelectedZoomScale: CGFloat = 1.2
    /// title的线宽是否允许粗细。使用该效果时，务必保证titleNormalFont和titleSelectedFont值相同。
    open var isTitleStrokeWidthEnabled: Bool = false
    /// 用于控制字体的粗细（底层通过NSStrokeWidthAttributeName实现），负数越小字体越粗。
    open var titleSelectedStrokeWidth: CGFloat = -2
    /// title是否使用遮罩过渡
    open var isTitleMaskEnabled: Bool = false

    open override func preferredItemCount() -> Int {
        return titles.count
    }

    open override func preferredItemModelInstance() -> MahaSegmentedBaseItemModel {
        return MahaSegmentedTitleItemModel()
    }

    open override func preferredRefreshItemModel( _ itemModel: MahaSegmentedBaseItemModel, at index: Int, selectedIndex: Int) {
        super.preferredRefreshItemModel(itemModel, at: index, selectedIndex: selectedIndex)

        guard let titleItemModel = itemModel as? MahaSegmentedTitleItemModel else {
            return
        }

        configureTitleItemModel(titleItemModel, at: index)
        updateTitleItemModelState(titleItemModel, isSelected: index == selectedIndex)
    }

    open func widthForTitle(_ title: String, _ index: Int) -> CGFloat {
        if let widthForTitleClosure {
            return widthForTitleClosure(title)
        }
        let textWidth = NSString(string: title).boundingRect(
            with: CGSize(width: CGFloat.infinity, height: CGFloat.infinity),
            options: [.usesFontLeading, .usesLineFragmentOrigin],
            attributes: [.font: resolvedTitleNormalFont(at: index)],
            context: nil
        ).size.width
        return CGFloat(ceilf(Float(textWidth)))
    }

    /// 因为该方法会被频繁调用，所以应该在`preferredRefreshItemModel( _ itemModel: MahaSegmentedBaseItemModel, at index: Int, selectedIndex: Int)`方法里面，根据数据源计算好文字宽度，然后缓存起来。该方法直接使用已经计算好的文字宽度即可。
    open override func preferredSegmentedView(_ segmentedView: MahaSegmentedView, widthForItemAt index: Int) -> CGFloat {
        var width = super.preferredSegmentedView(segmentedView, widthForItemAt: index)
        if itemWidth == MahaSegmentedViewAutomaticDimension {
            width += (dataSource[index] as! MahaSegmentedTitleItemModel).textWidth
        }else {
            width += itemWidth
        }
        return width
    }

    //MARK: - MahaSegmentedViewDataSource
    open override func registerCellClass(in segmentedView: MahaSegmentedView) {
        segmentedView.collectionView.register(MahaSegmentedTitleCell.self, forCellWithReuseIdentifier: "cell")
    }

    open override func segmentedView(_ segmentedView: MahaSegmentedView, cellForItemAt index: Int) -> MahaSegmentedBaseCell {
        return segmentedView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
    }

    public override func segmentedView(_ segmentedView: MahaSegmentedView, widthForItemContentAt index: Int) -> CGFloat {
        let model = dataSource[index] as! MahaSegmentedTitleItemModel
        if isTitleZoomEnabled {
            return model.textWidth*model.titleCurrentZoomScale
        }else {
            return model.textWidth
        }
    }

    open override func refreshItemModel(_ segmentedView: MahaSegmentedView, leftItemModel: MahaSegmentedBaseItemModel, rightItemModel: MahaSegmentedBaseItemModel, percent: CGFloat) {
        super.refreshItemModel(segmentedView, leftItemModel: leftItemModel, rightItemModel: rightItemModel, percent: percent)
        
        guard let leftModel = leftItemModel as? MahaSegmentedTitleItemModel, let rightModel = rightItemModel as? MahaSegmentedTitleItemModel else {
            return
        }

        if isTitleZoomEnabled && isItemTransitionEnabled {
            leftModel.titleCurrentZoomScale = MahaSegmentedViewTool.interpolate(from: leftModel.titleSelectedZoomScale, to: leftModel.titleNormalZoomScale, percent: CGFloat(percent))
            rightModel.titleCurrentZoomScale = MahaSegmentedViewTool.interpolate(from: rightModel.titleNormalZoomScale, to: rightModel.titleSelectedZoomScale, percent: CGFloat(percent))
        }

        if isTitleStrokeWidthEnabled && isItemTransitionEnabled {
            leftModel.titleCurrentStrokeWidth = MahaSegmentedViewTool.interpolate(from: leftModel.titleSelectedStrokeWidth, to: leftModel.titleNormalStrokeWidth, percent: CGFloat(percent))
            rightModel.titleCurrentStrokeWidth = MahaSegmentedViewTool.interpolate(from: rightModel.titleNormalStrokeWidth, to: rightModel.titleSelectedStrokeWidth, percent: CGFloat(percent))
        }

        if isTitleColorGradientEnabled && isItemTransitionEnabled {
            leftModel.titleCurrentColor = MahaSegmentedViewTool.interpolateThemeColor(from: leftModel.titleSelectedColor, to: leftModel.titleNormalColor, percent: percent)
            rightModel.titleCurrentColor = MahaSegmentedViewTool.interpolateThemeColor(from:rightModel.titleNormalColor , to:rightModel.titleSelectedColor, percent: percent)
        }
    }

    open override func refreshItemModel(_ segmentedView: MahaSegmentedView, currentSelectedItemModel: MahaSegmentedBaseItemModel, willSelectedItemModel: MahaSegmentedBaseItemModel, selectedType: MahaSegmentedViewItemSelectedType) {
        super.refreshItemModel(segmentedView, currentSelectedItemModel: currentSelectedItemModel, willSelectedItemModel: willSelectedItemModel, selectedType: selectedType)

        guard let currentTitleItemModel = currentSelectedItemModel as? MahaSegmentedTitleItemModel,
              let nextTitleItemModel = willSelectedItemModel as? MahaSegmentedTitleItemModel else {
            return
        }

        updateTitleItemModelState(currentTitleItemModel, isSelected: false)
        currentTitleItemModel.indicatorConvertToItemFrame = .zero
        updateTitleItemModelState(nextTitleItemModel, isSelected: true)
    }
    
    // MARK: - Configuration
    
    private func configureTitleItemModel(_ itemModel: MahaSegmentedTitleItemModel, at index: Int) {
        let title = titles[index]
        itemModel.title = title
        itemModel.textWidth = widthForTitle(title, index)
        itemModel.titleNumberOfLines = resolvedTitleNumberOfLines(at: index)
        itemModel.isSelectedAnimable = isSelectedAnimable
        itemModel.titleNormalColor = resolvedTitleNormalColor(at: index)
        itemModel.titleSelectedColor = resolvedTitleSelectedColor(at: index)
        itemModel.titleNormalFont = resolvedTitleNormalFont(at: index)
        itemModel.titleSelectedFont = resolvedTitleSelectedFont(at: index) ?? itemModel.titleNormalFont
        itemModel.isTitleZoomEnabled = isTitleZoomEnabled
        itemModel.isTitleStrokeWidthEnabled = isTitleStrokeWidthEnabled
        itemModel.isTitleMaskEnabled = isTitleMaskEnabled
        itemModel.titleNormalZoomScale = 1
        itemModel.titleSelectedZoomScale = titleSelectedZoomScale
        itemModel.titleSelectedStrokeWidth = titleSelectedStrokeWidth
        itemModel.titleNormalStrokeWidth = 0
    }

    private func updateTitleItemModelState(_ itemModel: MahaSegmentedTitleItemModel, isSelected: Bool) {
        itemModel.titleCurrentColor = isSelected ? itemModel.titleSelectedColor : itemModel.titleNormalColor
        itemModel.titleCurrentZoomScale = isSelected ? itemModel.titleSelectedZoomScale : itemModel.titleNormalZoomScale
        itemModel.titleCurrentStrokeWidth = isSelected ? itemModel.titleSelectedStrokeWidth : itemModel.titleNormalStrokeWidth
    }

    private func resolvedTitleNumberOfLines(at index: Int) -> Int {
        if let configuration {
            return configuration.titleNumberOfLines(at: index)
        }
        return titleNumberOfLines
    }

    private func resolvedTitleNormalColor(at index: Int) -> UIColor {
        if let configuration {
            return configuration.titleNormalColor(at: index)
        }
        return titleNormalColor
    }

    private func resolvedTitleSelectedColor(at index: Int) -> UIColor {
        if let configuration {
            return configuration.titleSelectedColor(at: index)
        }
        return titleSelectedColor
    }

    private func resolvedTitleNormalFont(at index: Int) -> UIFont {
        if let configuration {
            return configuration.titleNormalFont(at: index)
        }
        return titleNormalFont
    }

    private func resolvedTitleSelectedFont(at index: Int) -> UIFont? {
        if let configuration {
            return configuration.titleSelectedFont(at: index)
        }
        return titleSelectedFont
    }
}
