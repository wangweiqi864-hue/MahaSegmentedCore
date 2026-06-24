//
//  MahaSegmentedIndicatorBackgroundView.swift
//  MahaSegmentedView
//
//  Created by jiaxin on 2018/12/28.
//  Copyright © 2018 jiaxin. All rights reserved.
//

import UIKit

/// 不支持indicatorPosition、verticalOffset。默认垂直居中。
open class MahaSegmentedIndicatorBackgroundView: MahaSegmentedIndicatorBaseView {
    @available(*, deprecated, renamed: "indicatorWidthIncrement")
    open var backgroundWidthIncrement: CGFloat = 20 {
        didSet {
            indicatorWidthIncrement = backgroundWidthIncrement
        }
    }

    open override func commonInit() {
        super.commonInit()

        indicatorWidthIncrement = 20
        indicatorHeight = 26
        indicatorColor = .lightGray
        indicatorPosition = .center
        verticalOffset = 0
    }

    open override func refreshIndicatorState(model: MahaSegmentedIndicatorSelectedParams) {
        super.refreshIndicatorState(model: model)

        backgroundColor = indicatorColor
        layer.cornerRadius = getIndicatorCornerRadius(itemFrame: model.currentSelectedItemFrame)
        frame = indicatorFrame(itemFrame: model.currentSelectedItemFrame, itemContentWidth: model.currentItemContentWidth)
    }

    open override func contentScrollViewDidScroll(model: MahaSegmentedIndicatorTransitionParams) {
        super.contentScrollViewDidScroll(model: model)

        guard canHandleTransition(model: model) else {
            return
        }

        let leftItemFrame = model.leftItemFrame
        let rightItemFrame = model.rightItemFrame
        let percent = model.percent
        let leftWidth = getIndicatorWidth(itemFrame: leftItemFrame, itemContentWidth: model.leftItemContentWidth)
        let rightWidth = getIndicatorWidth(itemFrame: rightItemFrame, itemContentWidth: model.rightItemContentWidth)
        let leftX = centeredIndicatorX(itemFrame: leftItemFrame, indicatorWidth: leftWidth)
        let rightX = centeredIndicatorX(itemFrame: rightItemFrame, indicatorWidth: rightWidth)
        let targetX = MahaSegmentedViewTool.interpolate(from: leftX, to: rightX, percent: percent)
        var targetWidth = leftWidth
        if indicatorWidth == MahaSegmentedViewAutomaticDimension {
            targetWidth = MahaSegmentedViewTool.interpolate(from: leftWidth, to: rightWidth, percent: percent)
        }

        frame.origin.x = targetX
        frame.size.width = targetWidth
    }

    open override func selectItem(model: MahaSegmentedIndicatorSelectedParams) {
        super.selectItem(model: model)

        let targetWidth = getIndicatorWidth(itemFrame: model.currentSelectedItemFrame, itemContentWidth: model.currentItemContentWidth)
        var targetFrame = frame
        targetFrame.origin.x = centeredIndicatorX(itemFrame: model.currentSelectedItemFrame, indicatorWidth: targetWidth)
        targetFrame.size.width = targetWidth
        if canSelectedWithAnimation(model: model) {
            UIView.animate(withDuration: scrollAnimationDuration, delay: 0, options: .curveEaseOut, animations: {
                self.frame = targetFrame
            }) { (_) in
            }
        } else {
            frame = targetFrame
        }
    }
}
