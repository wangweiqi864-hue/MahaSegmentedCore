//
//  MahaSegmentedTitleAttributeCell.swift
//  MahaSegmentedView
//
//  Created by jiaxin on 2019/1/3.
//  Copyright © 2019 jiaxin. All rights reserved.
//

import UIKit

open class MahaSegmentedTitleAttributeCell: MahaSegmentedBaseCell {
    open var titleLabel = UILabel()

    open override func commonInit() {
        super.commonInit()

        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)

        let centerX = NSLayoutConstraint(item: titleLabel, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX, multiplier: 1, constant: 0)
        contentView.addConstraint(centerX)
        let centerY = NSLayoutConstraint(item: titleLabel, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1, constant: 0)
        contentView.addConstraint(centerY)
    }

    open override func reloadData(itemModel: MahaSegmentedBaseItemModel, selectedType: MahaSegmentedViewItemSelectedType) {
        super.reloadData(itemModel: itemModel, selectedType: selectedType )

        guard let attributeItemModel = itemModel as? MahaSegmentedTitleAttributeItemModel else {
            return
        }

        titleLabel.numberOfLines = attributeItemModel.titleNumberOfLines
        titleLabel.attributedText = displayedTitle(using: attributeItemModel)
    }

    private func displayedTitle(using itemModel: MahaSegmentedTitleAttributeItemModel) -> NSAttributedString? {
        if itemModel.isSelected, let selectedAttributedTitle = itemModel.selectedAttributedTitle {
            return selectedAttributedTitle
        }
        return itemModel.attributedTitle
    }
}
