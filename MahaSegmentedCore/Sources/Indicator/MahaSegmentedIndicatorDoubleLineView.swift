//
//  MahaSegmentedIndicatorDoubleLineView.swift
//  MahaSegmentedView
//
//  Created by jiaxin on 2019/1/16.
//  Copyright © 2019 jiaxin. All rights reserved.
//

import UIKit

open class MahaSegmentedIndicatorDoubleLineView: MahaSegmentedIndicatorBaseView {
    /// 线收缩到最小的百分比
    open var minLineWidthPercent: CGFloat = 0.2
    public let selectedLineView: UIView = UIView()
    public let otherLineView: UIView = UIView()

    open override func commonInit() {
        super.commonInit()

        indicatorHeight = 3

        addSubview(selectedLineView)

        otherLineView.alpha = 0
        addSubview(otherLineView)
    }

    open override func refreshIndicatorState(model: MahaSegmentedIndicatorSelectedParams) {
        super.refreshIndicatorState(model: model)

        selectedLineView.backgroundColor = indicatorColor
        otherLineView.backgroundColor = indicatorColor
        selectedLineView.layer.cornerRadius = getIndicatorCornerRadius(itemFrame: model.currentSelectedItemFrame)
        otherLineView.layer.cornerRadius = getIndicatorCornerRadius(itemFrame: model.currentSelectedItemFrame)
        selectedLineView.frame = indicatorFrame(itemFrame: model.currentSelectedItemFrame, itemContentWidth: model.currentItemContentWidth)
        otherLineView.frame = selectedLineView.frame
    }

    open override func contentScrollViewDidScroll(model: MahaSegmentedIndicatorTransitionParams) {
        super.contentScrollViewDidScroll(model: model)

        guard canHandleTransition(model: model) else {
            return
        }

        let rightItemFrame = model.rightItemFrame
        let leftItemFrame = model.leftItemFrame
        let percent = model.percent

        let leftCenter = getCenter(in: leftItemFrame)
        let rightCenter = getCenter(in: rightItemFrame)
        let leftMaxWidth = getIndicatorWidth(itemFrame: leftItemFrame, itemContentWidth: model.leftItemContentWidth)
        let rightMaxWidth = getIndicatorWidth(itemFrame: rightItemFrame, itemContentWidth: model.rightItemContentWidth)
        let leftMinWidth = leftMaxWidth*minLineWidthPercent
        let rightMinWidth = rightMaxWidth*minLineWidthPercent

        let leftWidth: CGFloat = MahaSegmentedViewTool.interpolate(from: leftMaxWidth, to: leftMinWidth, percent: percent)
        let rightWidth: CGFloat = MahaSegmentedViewTool.interpolate(from: rightMinWidth, to: rightMaxWidth, percent: percent)
        let leftAlpha: CGFloat = MahaSegmentedViewTool.interpolate(from: 1, to: 0, percent: percent)
        let rightAlpha: CGFloat = MahaSegmentedViewTool.interpolate(from: 0, to: 1, percent: percent)

        if model.currentSelectedIndex == model.leftIndex {
            selectedLineView.bounds.size.width = leftWidth
            selectedLineView.center = leftCenter
            selectedLineView.alpha = leftAlpha

            otherLineView.bounds.size.width = rightWidth
            otherLineView.center = rightCenter
            otherLineView.alpha = rightAlpha
        } else {
            otherLineView.bounds.size.width = leftWidth
            otherLineView.center = leftCenter
            otherLineView.alpha = leftAlpha

            selectedLineView.bounds.size.width = rightWidth
            selectedLineView.center = rightCenter
            selectedLineView.alpha = rightAlpha
        }
    }

    open override func selectItem(model: MahaSegmentedIndicatorSelectedParams) {
        super.selectItem(model: model)

        let targetWidth = getIndicatorWidth(itemFrame: model.currentSelectedItemFrame, itemContentWidth: model.currentItemContentWidth)
        let targetCenter = getCenter(in: model.currentSelectedItemFrame)
        selectedLineView.bounds.size.width = targetWidth
        selectedLineView.center = targetCenter
        selectedLineView.alpha = 1

        otherLineView.alpha = 0
    }

    private func getCenter(in frame: CGRect) -> CGPoint {
        return CGPoint(x: frame.midX, y: selectedLineView.center.y)
    }
}
