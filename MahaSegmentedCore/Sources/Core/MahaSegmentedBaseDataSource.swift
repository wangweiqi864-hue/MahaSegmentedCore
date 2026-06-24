//
//  MahaSegmentedBaseDataSource.swift
//  MahaSegmentedView
//
//  Created by jiaxin on 2018/12/28.
//  Copyright © 2018 jiaxin. All rights reserved.
//

import Foundation
import  UIKit

open class MahaSegmentedBaseDataSource: MahaSegmentedViewDataSource {
    /// 最终传递给MahaSegmentedView的数据源数组
    open var dataSource = [MahaSegmentedBaseItemModel]()
    /// cell的宽度。为MahaSegmentedViewAutomaticDimension时就以内容计算的宽度为准，否则以itemWidth的具体值为准。
    open var itemWidth: CGFloat = MahaSegmentedViewAutomaticDimension
    /// 真实的item宽度 = itemWidth + itemWidthIncrement。
    open var itemWidthIncrement: CGFloat = 0
    /// item之前的间距
    open var itemSpacing: CGFloat = 20
    /// 当collectionView.contentSize.width小于MahaSegmentedView的宽度时，是否将itemSpacing均分。
    open var isItemSpacingAverageEnabled: Bool = true
    /// item左右滚动过渡时，是否允许渐变。比如MahaSegmentedTitleDataSource的titleZoom、titleNormalColor、titleStrokeWidth等渐变。
    open var isItemTransitionEnabled: Bool = true
    /// 选中的时候，是否需要动画过渡。自定义的cell需要自己处理动画过渡逻辑，动画处理逻辑参考`MahaSegmentedTitleCell`
    open var isSelectedAnimable: Bool = false
    /// 选中动画的时长
    open var selectedAnimationDuration: TimeInterval = 0.25
    /// 是否允许item宽度缩放
    open var isItemWidthZoomEnabled: Bool = false
    /// 是否允许item宽度缩放动画
    open var isItemWidthZoomAnimable: Bool = true
    /// item宽度选中时的scale
    open var itemWidthSelectedZoomScale: CGFloat = 1.5

    @available(*, deprecated, renamed: "itemWidth")
    open var itemContentWidth: CGFloat = MahaSegmentedViewAutomaticDimension {
        didSet {
            itemWidth = itemContentWidth
        }
    }

    private var selectionAnimator: MahaSegmentedAnimator?

    deinit {
        selectionAnimator?.stop()
    }

    public init() {
    }

    /// 配置完各种属性之后，需要手动调用该方法，更新数据源
    ///
    /// - Parameter selectedIndex: 当前选中的index
    open func reloadData(selectedIndex: Int) {
        dataSource.removeAll(keepingCapacity: true)
        for index in 0..<preferredItemCount() {
            let itemModel = preferredItemModelInstance()
            preferredRefreshItemModel(itemModel, at: index, selectedIndex: selectedIndex)
            dataSource.append(itemModel)
        }
    }

    open func preferredItemCount() -> Int {
        return 0
    }

    /// 子类需要重载该方法，用于返回自己定义的MahaSegmentedBaseItemModel子类实例
    open func preferredItemModelInstance() -> MahaSegmentedBaseItemModel  {
        return MahaSegmentedBaseItemModel()
    }

    /// 子类需要重载该方法，用于返回索引为index的item宽度
    open func preferredSegmentedView(_ segmentedView: MahaSegmentedView, widthForItemAt index: Int) -> CGFloat {
        return itemWidthIncrement
    }

    /// 子类需要重载该方法，用于更新索引为index的itemModel
    open func preferredRefreshItemModel(_ itemModel: MahaSegmentedBaseItemModel, at index: Int, selectedIndex: Int) {
        configureBaseItemModel(itemModel, at: index)
        if index == selectedIndex {
            itemModel.isSelected = true
            itemModel.itemWidthCurrentZoomScale = itemModel.itemWidthSelectedZoomScale
        } else {
            itemModel.isSelected = false
            itemModel.itemWidthCurrentZoomScale = itemModel.itemWidthNormalZoomScale
        }
    }

    //MARK: - MahaSegmentedViewDataSource
    open func itemDataSource(in segmentedView: MahaSegmentedView) -> [MahaSegmentedBaseItemModel] {
        return dataSource
    }

    /// 自定义子类请继承方法`func preferredWidthForItem(at index: Int) -> CGFloat`
    public final func segmentedView(_ segmentedView: MahaSegmentedView, widthForItemAt index: Int) -> CGFloat {
        return preferredSegmentedView(segmentedView, widthForItemAt: index)
    }

    public func segmentedView(_ segmentedView: MahaSegmentedView, widthForItemContentAt index: Int) -> CGFloat {
        return self.segmentedView(segmentedView, widthForItemAt: index)
    }

    open func registerCellClass(in segmentedView: MahaSegmentedView) {

    }

    open func segmentedView(_ segmentedView: MahaSegmentedView, cellForItemAt index: Int) -> MahaSegmentedBaseCell {
        return MahaSegmentedBaseCell()
    }

    open func refreshItemModel(_ segmentedView: MahaSegmentedView, currentSelectedItemModel: MahaSegmentedBaseItemModel, willSelectedItemModel: MahaSegmentedBaseItemModel, selectedType: MahaSegmentedViewItemSelectedType) {
        currentSelectedItemModel.isSelected = false
        willSelectedItemModel.isSelected = true

        guard isItemWidthZoomEnabled else {
            currentSelectedItemModel.itemWidthCurrentZoomScale = currentSelectedItemModel.itemWidthNormalZoomScale
            willSelectedItemModel.itemWidthCurrentZoomScale = willSelectedItemModel.itemWidthSelectedZoomScale
            return
        }

        guard shouldHandleWidthZoomTransition(for: selectedType) else {
            return
        }

        selectionAnimator?.stop()
        let animator = MahaSegmentedAnimator()
        animator.duration = selectedAnimationDuration
        animator.progressClosure = { [weak self] percent in
            self?.applyWidthZoomTransition(
                in: segmentedView,
                currentSelectedItemModel: currentSelectedItemModel,
                willSelectedItemModel: willSelectedItemModel,
                percent: percent
            )
        }
        selectionAnimator = animator
        if isItemWidthZoomAnimable {
            animator.start()
        } else {
            animator.stop()
        }
    }

    open func refreshItemModel(_ segmentedView: MahaSegmentedView, leftItemModel: MahaSegmentedBaseItemModel, rightItemModel: MahaSegmentedBaseItemModel, percent: CGFloat) {
        //如果正在进行itemWidth缩放动画，用户又立马滚动了contentScrollView，需要停止动画。
        selectionAnimator?.stop()
        selectionAnimator = nil
        if isItemWidthZoomEnabled && isItemTransitionEnabled {
            //允许itemWidth缩放动画且允许item渐变过渡
            leftItemModel.itemWidthCurrentZoomScale = MahaSegmentedViewTool.interpolate(from: leftItemModel.itemWidthSelectedZoomScale, to: leftItemModel.itemWidthNormalZoomScale, percent: percent)
            leftItemModel.itemWidth = itemWidth(in: segmentedView, at: leftItemModel.index, model: leftItemModel)
            rightItemModel.itemWidthCurrentZoomScale = MahaSegmentedViewTool.interpolate(from: rightItemModel.itemWidthNormalZoomScale, to: rightItemModel.itemWidthSelectedZoomScale, percent: percent)
            rightItemModel.itemWidth = itemWidth(in: segmentedView, at: rightItemModel.index, model: rightItemModel)
            segmentedView.collectionView.collectionViewLayout.invalidateLayout()
        }
    }

    /// 自定义子类请继承方法`func preferredRefreshItemModel(_ itemModel: MahaSegmentedBaseItemModel, at index: Int, selectedIndex: Int)`
    public final func refreshItemModel(_ segmentedView: MahaSegmentedView, _ itemModel: MahaSegmentedBaseItemModel, at index: Int, selectedIndex: Int) {
        preferredRefreshItemModel(itemModel, at: index, selectedIndex: selectedIndex)
    }

    private func configureBaseItemModel(_ itemModel: MahaSegmentedBaseItemModel, at index: Int) {
        itemModel.index = index
        itemModel.isItemTransitionEnabled = isItemTransitionEnabled
        itemModel.isSelectedAnimable = isSelectedAnimable
        itemModel.selectedAnimationDuration = selectedAnimationDuration
        itemModel.isItemWidthZoomEnabled = isItemWidthZoomEnabled
        itemModel.itemWidthNormalZoomScale = 1
        itemModel.itemWidthSelectedZoomScale = itemWidthSelectedZoomScale
    }

    private func shouldHandleWidthZoomTransition(for selectedType: MahaSegmentedViewItemSelectedType) -> Bool {
        return (selectedType == .scroll && !isItemTransitionEnabled) || selectedType == .click || selectedType == .code
    }

    private func applyWidthZoomTransition(in segmentedView: MahaSegmentedView,
                                          currentSelectedItemModel: MahaSegmentedBaseItemModel,
                                          willSelectedItemModel: MahaSegmentedBaseItemModel,
                                          percent: CGFloat) {
        currentSelectedItemModel.itemWidthCurrentZoomScale = MahaSegmentedViewTool.interpolate(from: currentSelectedItemModel.itemWidthSelectedZoomScale, to: currentSelectedItemModel.itemWidthNormalZoomScale, percent: percent)
        currentSelectedItemModel.itemWidth = itemWidth(in: segmentedView, at: currentSelectedItemModel.index, model: currentSelectedItemModel)
        willSelectedItemModel.itemWidthCurrentZoomScale = MahaSegmentedViewTool.interpolate(from: willSelectedItemModel.itemWidthNormalZoomScale, to: willSelectedItemModel.itemWidthSelectedZoomScale, percent: percent)
        willSelectedItemModel.itemWidth = itemWidth(in: segmentedView, at: willSelectedItemModel.index, model: willSelectedItemModel)
        segmentedView.collectionView.collectionViewLayout.invalidateLayout()
    }

    private func itemWidth(in segmentedView: MahaSegmentedView, at index: Int, model: MahaSegmentedBaseItemModel) -> CGFloat {
        var width = self.segmentedView(segmentedView, widthForItemAt: index)
        if isItemWidthZoomEnabled {
            width *= model.itemWidthCurrentZoomScale
        }
        return width
    }
}
