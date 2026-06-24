//
//  MahaSegmentedIndicatorLineView.swift
//  MahaSegmentedView
//
//  Created by jiaxin on 2018/12/26.
//  Copyright © 2018 jiaxin. All rights reserved.
//

import UIKit

public enum MahaSegmentedIndicatorLineStyle {
    case normal
    case lengthen
    case lengthenOffset
}

open class MahaSegmentedIndicatorLineView: MahaSegmentedIndicatorBaseView {
    open var lineStyle: MahaSegmentedIndicatorLineStyle = .normal
    /// lineStyle为lengthenOffset时使用，滚动时x的偏移量
    open var lineScrollOffsetX: CGFloat = 10

    open override func commonInit() {
        super.commonInit()

        indicatorHeight = 3
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
        var targetX = leftX
        var targetWidth = leftWidth

        switch lineStyle {
        case .normal:
            targetX = MahaSegmentedViewTool.interpolate(from: leftX, to: rightX, percent: percent)
            if indicatorWidth == MahaSegmentedViewAutomaticDimension {
                targetWidth = MahaSegmentedViewTool.interpolate(from: leftWidth, to: rightWidth, percent: percent)
            }
        case .lengthen:
            //前50%，只增加width；后50%，移动x并减小width
            let maxWidth = rightX - leftX + rightWidth
            if percent <= 0.5 {
                targetX = leftX
                targetWidth = MahaSegmentedViewTool.interpolate(from: leftWidth, to: maxWidth, percent: percent * 2)
            } else {
                targetX = MahaSegmentedViewTool.interpolate(from: leftX, to: rightX, percent: (percent - 0.5) * 2)
                targetWidth = MahaSegmentedViewTool.interpolate(from: maxWidth, to: rightWidth, percent: (percent - 0.5) * 2)
            }
        case .lengthenOffset:
            //前50%，增加width，并少量移动x；后50%，少量移动x并减小width
            let maxWidth = rightX - leftX + rightWidth - lineScrollOffsetX * 2
            if percent <= 0.5 {
                targetX = MahaSegmentedViewTool.interpolate(from: leftX, to: leftX + lineScrollOffsetX, percent: percent * 2)
                targetWidth = MahaSegmentedViewTool.interpolate(from: leftWidth, to: maxWidth, percent: percent * 2)
            } else {
                targetX = MahaSegmentedViewTool.interpolate(from: leftX + lineScrollOffsetX, to: rightX, percent: (percent - 0.5) * 2)
                targetWidth = MahaSegmentedViewTool.interpolate(from: maxWidth, to: rightWidth, percent: (percent - 0.5) * 2)
            }
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
