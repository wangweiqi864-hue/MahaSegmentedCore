//
//  MahaSegmentedTitleCell.swift
//  MahaSegmentedView
//
//  Created by jiaxin on 2018/12/26.
//  Copyright © 2018 jiaxin. All rights reserved.
//

import UIKit

open class MahaSegmentedTitleCell: MahaSegmentedBaseCell {
    public let titleLabel = UILabel()
    public let maskTitleLabel = UILabel()
    public let titleMaskLayer = CALayer()
    public let maskTitleMaskLayer = CALayer()

    open override func commonInit() {
        super.commonInit()

        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)

        maskTitleLabel.textAlignment = .center
        maskTitleLabel.isHidden = true
        contentView.addSubview(maskTitleLabel)

        titleMaskLayer.backgroundColor = UIColor.red.cgColor

        maskTitleMaskLayer.backgroundColor = UIColor.red.cgColor
        maskTitleLabel.layer.mask = maskTitleMaskLayer
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        //为什么使用`sizeThatFits`，而不用`sizeToFit`呢？在numberOfLines大于0的时候，cell进行重用的时候通过`sizeToFit`，label设置成错误的size。至于原因我用尽毕生所学，没有找到为什么。但是用`sizeThatFits`可以规避掉这个问题。
        let labelSize = titleLabel.sizeThatFits(self.contentView.bounds.size)
        let labelBounds = CGRect(x: 0, y: 0, width: labelSize.width, height: labelSize.height)
        titleLabel.bounds = labelBounds
        titleLabel.center = contentView.center

        maskTitleLabel.bounds = labelBounds
        maskTitleLabel.center = contentView.center
    }

    open override func reloadData(itemModel: MahaSegmentedBaseItemModel, selectedType: MahaSegmentedViewItemSelectedType) {
        super.reloadData(itemModel: itemModel, selectedType: selectedType )

        guard let titleItemModel = itemModel as? MahaSegmentedTitleItemModel else {
            return
        }

        applyNumberOfLines(using: titleItemModel)
        updateTitleFont(using: titleItemModel, sourceItemModel: itemModel, selectedType: selectedType)
        let attributedTitle = attributedTitle(for: titleItemModel)
        updateAttributedTitle(attributedTitle, using: titleItemModel, sourceItemModel: itemModel, selectedType: selectedType)
        updateMaskState(using: titleItemModel, sourceItemModel: itemModel, selectedType: selectedType)
        startSelectedAnimationIfNeeded(itemModel: itemModel, selectedType: selectedType)
        setNeedsLayout()
    }

    open func preferredTitleZoomAnimateClosure(itemModel: MahaSegmentedTitleItemModel, baseScale: CGFloat) -> MahaSegmentedCellSelectedAnimationClosure {
        return { [weak self] percent in
            itemModel.titleCurrentZoomScale = itemModel.isSelected
                ? MahaSegmentedViewTool.interpolate(from: itemModel.titleNormalZoomScale, to: itemModel.titleSelectedZoomScale, percent: percent)
                : MahaSegmentedViewTool.interpolate(from: itemModel.titleSelectedZoomScale, to: itemModel.titleNormalZoomScale, percent: percent)
            let currentTransform = CGAffineTransform(scaleX: baseScale * itemModel.titleCurrentZoomScale, y: baseScale * itemModel.titleCurrentZoomScale)
            self?.titleLabel.transform = currentTransform
            self?.maskTitleLabel.transform = currentTransform
        }
    }

    open func preferredTitleStrokeWidthAnimateClosure(itemModel: MahaSegmentedTitleItemModel, attriText: NSMutableAttributedString) -> MahaSegmentedCellSelectedAnimationClosure{
        return { [weak self] percent in
            itemModel.titleCurrentStrokeWidth = itemModel.isSelected
                ? MahaSegmentedViewTool.interpolate(from: itemModel.titleNormalStrokeWidth, to: itemModel.titleSelectedStrokeWidth, percent: percent)
                : MahaSegmentedViewTool.interpolate(from: itemModel.titleSelectedStrokeWidth, to: itemModel.titleNormalStrokeWidth, percent: percent)
            attriText.addAttributes([NSAttributedString.Key.strokeWidth: itemModel.titleCurrentStrokeWidth], range: NSRange(location: 0, length: attriText.string.count))
            self?.titleLabel.attributedText = attriText
            self?.maskTitleLabel.attributedText = attriText
        }
    }

    open func preferredTitleColorAnimateClosure(itemModel: MahaSegmentedTitleItemModel) -> MahaSegmentedCellSelectedAnimationClosure {
        return { [weak self] percent in
            itemModel.titleCurrentColor = itemModel.isSelected
                ? MahaSegmentedViewTool.interpolateThemeColor(from: itemModel.titleNormalColor, to: itemModel.titleSelectedColor, percent: percent)
                : MahaSegmentedViewTool.interpolateThemeColor(from: itemModel.titleSelectedColor, to: itemModel.titleNormalColor, percent: percent)
            self?.titleLabel.textColor = itemModel.titleCurrentColor
        }
    }
    
    override func setSelectedStyle(isSelected: Bool) {
        if isSelected {
            self.titleLabel.textColor = (self.itemModel as? MahaSegmentedTitleItemModel)?.titleSelectedColor
        } else {
            self.titleLabel.textColor = (self.itemModel as? MahaSegmentedTitleItemModel)?.titleNormalColor
        }
    }

    private func applyNumberOfLines(using itemModel: MahaSegmentedTitleItemModel) {
        titleLabel.numberOfLines = itemModel.titleNumberOfLines
        maskTitleLabel.numberOfLines = itemModel.titleNumberOfLines
    }

    private func updateTitleFont(using itemModel: MahaSegmentedTitleItemModel,
                                 sourceItemModel: MahaSegmentedBaseItemModel,
                                 selectedType: MahaSegmentedViewItemSelectedType) {
        guard itemModel.isTitleZoomEnabled else {
            let font = itemModel.isSelected ? itemModel.titleSelectedFont : itemModel.titleNormalFont
            titleLabel.font = font
            maskTitleLabel.font = font
            titleLabel.transform = .identity
            maskTitleLabel.transform = .identity
            return
        }

        let maxScaleFont = UIFont(
            descriptor: itemModel.titleNormalFont.fontDescriptor,
            size: itemModel.titleNormalFont.pointSize * itemModel.titleSelectedZoomScale
        )
        let baseScale = itemModel.titleNormalFont.lineHeight / maxScaleFont.lineHeight
        if itemModel.isSelectedAnimable && canStartSelectedAnimation(itemModel: sourceItemModel, selectedType: selectedType) {
            appendSelectedAnimationClosure(closure: preferredTitleZoomAnimateClosure(itemModel: itemModel, baseScale: baseScale))
            return
        }

        titleLabel.font = maxScaleFont
        maskTitleLabel.font = maxScaleFont
        let currentTransform = CGAffineTransform(scaleX: baseScale * itemModel.titleCurrentZoomScale, y: baseScale * itemModel.titleCurrentZoomScale)
        titleLabel.transform = currentTransform
        maskTitleLabel.transform = currentTransform
    }

    private func attributedTitle(for itemModel: MahaSegmentedTitleItemModel) -> NSMutableAttributedString {
        return NSMutableAttributedString(string: itemModel.title ?? "")
    }

    private func updateAttributedTitle(_ attributedTitle: NSMutableAttributedString,
                                       using itemModel: MahaSegmentedTitleItemModel,
                                       sourceItemModel: MahaSegmentedBaseItemModel,
                                       selectedType: MahaSegmentedViewItemSelectedType) {
        guard itemModel.isTitleStrokeWidthEnabled else {
            titleLabel.attributedText = attributedTitle
            maskTitleLabel.attributedText = attributedTitle
            return
        }

        if itemModel.isSelectedAnimable && canStartSelectedAnimation(itemModel: sourceItemModel, selectedType: selectedType) {
            appendSelectedAnimationClosure(closure: preferredTitleStrokeWidthAnimateClosure(itemModel: itemModel, attriText: attributedTitle))
            return
        }

        attributedTitle.addAttributes([.strokeWidth: itemModel.titleCurrentStrokeWidth], range: NSRange(location: 0, length: attributedTitle.string.count))
        titleLabel.attributedText = attributedTitle
        maskTitleLabel.attributedText = attributedTitle
    }

    private func updateMaskState(using itemModel: MahaSegmentedTitleItemModel,
                                 sourceItemModel: MahaSegmentedBaseItemModel,
                                 selectedType: MahaSegmentedViewItemSelectedType) {
        guard itemModel.isTitleMaskEnabled else {
            maskTitleLabel.isHidden = true
            titleLabel.layer.mask = nil
            if itemModel.isSelectedAnimable && canStartSelectedAnimation(itemModel: sourceItemModel, selectedType: selectedType) {
                appendSelectedAnimationClosure(closure: preferredTitleColorAnimateClosure(itemModel: itemModel))
            } else {
                titleLabel.textColor = itemModel.titleCurrentColor
            }
            return
        }

        maskTitleLabel.isHidden = false
        titleLabel.textColor = itemModel.titleNormalColor
        maskTitleLabel.textColor = itemModel.titleSelectedColor
        let labelSize = maskTitleLabel.sizeThatFits(contentView.bounds.size)
        maskTitleLabel.bounds = CGRect(origin: .zero, size: labelSize)

        let maskFrames = maskFrames(for: itemModel)
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        if maskFrames.top.size.width > 0 && maskFrames.top.intersects(maskTitleLabel.frame) {
            titleLabel.layer.mask = titleMaskLayer
            titleMaskLayer.frame = maskFrames.bottom
            maskTitleMaskLayer.frame = maskFrames.top
        } else {
            titleLabel.layer.mask = nil
            maskTitleMaskLayer.frame = maskFrames.top
        }
        CATransaction.commit()
    }

    private func maskFrames(for itemModel: MahaSegmentedTitleItemModel) -> (top: CGRect, bottom: CGRect) {
        var topMaskFrame = itemModel.indicatorConvertToItemFrame
        topMaskFrame.origin.y = 0
        var bottomMaskFrame = topMaskFrame
        let maskStartX: CGFloat
        if maskTitleLabel.bounds.size.width >= bounds.size.width {
            topMaskFrame.origin.x -= (maskTitleLabel.bounds.size.width - bounds.size.width) / 2
            bottomMaskFrame.size.width = maskTitleLabel.bounds.size.width
            maskStartX = -(maskTitleLabel.bounds.size.width - bounds.size.width) / 2
        } else {
            topMaskFrame.origin.x -= (bounds.size.width - maskTitleLabel.bounds.size.width) / 2
            bottomMaskFrame.size.width = bounds.size.width
            maskStartX = 0
        }
        bottomMaskFrame.origin.x = topMaskFrame.origin.x > maskStartX ? topMaskFrame.origin.x - bottomMaskFrame.size.width : topMaskFrame.maxX
        return (topMaskFrame, bottomMaskFrame)
    }
}
