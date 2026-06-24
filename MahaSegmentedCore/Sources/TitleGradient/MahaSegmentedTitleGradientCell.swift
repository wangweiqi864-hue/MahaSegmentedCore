//
//  MahaSegmentedTitleGradientCell.swift
//  MahaSegmentedView
//
//  Created by jiaxin on 2019/1/23.
//  Copyright © 2019 jiaxin. All rights reserved.
//

import UIKit

open class MahaSegmentedTitleGradientCell: MahaSegmentedTitleCell {
    public let gradientLayer = CAGradientLayer()
    private var canStartSelectedAnimation: Bool = false

    open override func commonInit() {
        super.commonInit()

        titleLabel.removeFromSuperview()
        maskTitleLabel.removeFromSuperview()

        gradientLayer.colors = [UIColor.red.cgColor, UIColor.yellow.cgColor, UIColor.green.cgColor]
        contentView.layer.addSublayer(gradientLayer)
        gradientLayer.mask = titleLabel.layer
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        gradientLayer.frame = titleLabel.frame
        CATransaction.commit()
        titleLabel.frame = gradientLayer.bounds
    }

    open override func reloadData(itemModel: MahaSegmentedBaseItemModel, selectedType: MahaSegmentedViewItemSelectedType) {
        super.reloadData(itemModel: itemModel, selectedType: selectedType)

        guard let gradientItemModel = itemModel as? MahaSegmentedTitleGradientItemModel else {
            return
        }

        if gradientItemModel.isSelectedAnimable && canStartSelectedAnimation(itemModel: gradientItemModel, selectedType: selectedType) {
            appendSelectedAnimationClosure(closure: gradientColorAnimationClosure(for: gradientItemModel))
            canStartSelectedAnimation = true
            startSelectedAnimationIfNeeded(itemModel: gradientItemModel, selectedType: selectedType)
            canStartSelectedAnimation = false
        } else {
            updateGradientLayer(using: gradientItemModel)
        }
    }

    open override func startSelectedAnimationIfNeeded(itemModel: MahaSegmentedBaseItemModel, selectedType: MahaSegmentedViewItemSelectedType) {
        if canStartSelectedAnimation {
            super.startSelectedAnimationIfNeeded(itemModel: itemModel, selectedType: selectedType)
        }
    }

    private func gradientColorAnimationClosure(for itemModel: MahaSegmentedTitleGradientItemModel) -> MahaSegmentedCellSelectedAnimationClosure {
        return { [weak self] percent in
            itemModel.titleCurrentGradientColors = itemModel.isSelected
                ? MahaSegmentedViewTool.interpolateColors(from: itemModel.titleNormalGradientColors, to: itemModel.titleSelectedGradientColors, percent: percent)
                : MahaSegmentedViewTool.interpolateColors(from: itemModel.titleSelectedGradientColors, to: itemModel.titleNormalGradientColors, percent: percent)
            self?.updateGradientLayer(using: itemModel)
            self?.setNeedsLayout()
            self?.layoutIfNeeded()
        }
    }

    private func updateGradientLayer(using itemModel: MahaSegmentedTitleGradientItemModel) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        gradientLayer.startPoint = itemModel.titleGradientStartPoint
        gradientLayer.endPoint = itemModel.titleGradientEndPoint
        gradientLayer.colors = itemModel.titleCurrentGradientColors
        CATransaction.commit()
    }
}
