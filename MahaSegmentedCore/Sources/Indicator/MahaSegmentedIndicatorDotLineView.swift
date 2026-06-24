//
//  MahaSegmentedIndicatorDotLineView.swift
//  MahaSegmentedView
//
//  Created by jiaxin on 2019/1/16.
//  Copyright © 2019 jiaxin. All rights reserved.
//

import UIKit

open class MahaSegmentedIndicatorDotLineView: MahaSegmentedIndicatorBaseView {
    /// 线的最大宽度
    open var lineMaxWidth: CGFloat = 50

    open override func commonInit() {
        super.commonInit()

        //配置点的size
        indicatorWidth = 10
        indicatorHeight = 10
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
        let dotWidth = getIndicatorWidth(itemFrame: leftItemFrame, itemContentWidth: model.leftItemContentWidth)
        let leftWidth = dotWidth
        let rightWidth = getIndicatorWidth(itemFrame: rightItemFrame, itemContentWidth: model.rightItemContentWidth)
        let leftX = centeredIndicatorX(itemFrame: leftItemFrame, indicatorWidth: leftWidth)
        let rightX = centeredIndicatorX(itemFrame: rightItemFrame, indicatorWidth: rightWidth)
        let centerX = leftX + (rightX - leftX - lineMaxWidth) / 2
        var targetX = leftX
        var targetWidth = dotWidth

        //前50%，移动x，增加宽度；后50%，移动x并减小width
        if percent <= 0.5 {
            targetX = MahaSegmentedViewTool.interpolate(from: leftX, to: centerX, percent: percent * 2)
            targetWidth = MahaSegmentedViewTool.interpolate(from: dotWidth, to: lineMaxWidth, percent: percent * 2)
        } else {
            targetX = MahaSegmentedViewTool.interpolate(from: centerX, to: rightX, percent: (percent - 0.5) * 2)
            targetWidth = MahaSegmentedViewTool.interpolate(from: lineMaxWidth, to: dotWidth, percent: (percent - 0.5) * 2)
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
