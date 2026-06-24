//
//  MahaSegmentedTitleImageCell.swift
//  MahaSegmentedView
//
//  Created by jiaxin on 2018/12/29.
//  Copyright © 2018 jiaxin. All rights reserved.
//

import UIKit

open class MahaSegmentedTitleImageCell: MahaSegmentedTitleCell {
    public let imageView = UIImageView()
    private var currentImageInfo: String?

    open override func prepareForReuse() {
        super.prepareForReuse()

        currentImageInfo = nil
    }

    open override func commonInit() {
        super.commonInit()

        imageView.contentMode = .scaleAspectFit
        contentView.addSubview(imageView)
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        guard let titleImageItemModel = itemModel as? MahaSegmentedTitleImageItemModel else {
            return
        }

        layoutContent(using: titleImageItemModel)
    }

    open override func reloadData(itemModel: MahaSegmentedBaseItemModel, selectedType: MahaSegmentedViewItemSelectedType) {
        super.reloadData(itemModel: itemModel, selectedType: selectedType )

        guard let titleImageItemModel = itemModel as? MahaSegmentedTitleImageItemModel else {
            return
        }

        updateHiddenState(using: titleImageItemModel)
        imageView.bounds = CGRect(origin: .zero, size: titleImageItemModel.imageSize)
        loadImageIfNeeded(using: titleImageItemModel)
        updateImageTransform(using: titleImageItemModel)
        setNeedsLayout()
    }

    private func layoutContent(using itemModel: MahaSegmentedTitleImageItemModel) {
        let imageSize = itemModel.imageSize
        switch itemModel.titleImageType {
        case .topImage:
            let contentHeight = imageSize.height + itemModel.titleImageSpacing + titleLabel.bounds.size.height
            imageView.center = CGPoint(x: contentView.bounds.size.width / 2, y: (contentView.bounds.size.height - contentHeight) / 2 + imageSize.height / 2)
            titleLabel.center = CGPoint(x: contentView.bounds.size.width / 2, y: imageView.frame.maxY + itemModel.titleImageSpacing + titleLabel.bounds.size.height / 2)
        case .leftImage:
            let contentWidth = imageSize.width + itemModel.titleImageSpacing + titleLabel.bounds.size.width
            imageView.center = CGPoint(x: (contentView.bounds.size.width - contentWidth) / 2 + imageSize.width / 2, y: contentView.bounds.size.height / 2)
            titleLabel.center = CGPoint(x: imageView.frame.maxX + itemModel.titleImageSpacing + titleLabel.bounds.size.width / 2, y: contentView.bounds.size.height / 2)
        case .bottomImage:
            let contentHeight = imageSize.height + itemModel.titleImageSpacing + titleLabel.bounds.size.height
            titleLabel.center = CGPoint(x: contentView.bounds.size.width / 2, y: (contentView.bounds.size.height - contentHeight) / 2 + titleLabel.bounds.size.height / 2)
            imageView.center = CGPoint(x: contentView.bounds.size.width / 2, y: titleLabel.frame.maxY + itemModel.titleImageSpacing + imageSize.height / 2)
        case .rightImage:
            let contentWidth = imageSize.width + itemModel.titleImageSpacing + titleLabel.bounds.size.width
            titleLabel.center = CGPoint(x: (contentView.bounds.size.width - contentWidth) / 2 + titleLabel.bounds.size.width / 2, y: contentView.bounds.size.height / 2)
            imageView.center = CGPoint(x: titleLabel.frame.maxX + itemModel.titleImageSpacing + imageSize.width / 2, y: contentView.bounds.size.height / 2)
        case .onlyImage:
            imageView.center = CGPoint(x: contentView.bounds.size.width / 2, y: contentView.bounds.size.height / 2)
        case .onlyTitle:
            titleLabel.center = CGPoint(x: contentView.bounds.size.width / 2, y: contentView.bounds.size.height / 2)
        }
    }

    private func updateHiddenState(using itemModel: MahaSegmentedTitleImageItemModel) {
        titleLabel.isHidden = itemModel.titleImageType == .onlyImage
        imageView.isHidden = itemModel.titleImageType == .onlyTitle
    }

    private func loadImageIfNeeded(using itemModel: MahaSegmentedTitleImageItemModel) {
        let targetImageInfo = resolvedImageInfo(using: itemModel)
        guard let targetImageInfo, targetImageInfo != currentImageInfo else {
            return
        }
        currentImageInfo = targetImageInfo
        if let loadImageClosure = itemModel.loadImageClosure {
            loadImageClosure(imageView, targetImageInfo)
        } else {
            imageView.image = UIImage(named: targetImageInfo)
        }
    }

    private func resolvedImageInfo(using itemModel: MahaSegmentedTitleImageItemModel) -> String? {
        if itemModel.isSelected, let selectedImageInfo = itemModel.selectedImageInfo {
            return selectedImageInfo
        }
        return itemModel.normalImageInfo
    }

    private func updateImageTransform(using itemModel: MahaSegmentedTitleImageItemModel) {
        if itemModel.isImageZoomEnabled {
            imageView.transform = CGAffineTransform(scaleX: itemModel.imageCurrentZoomScale, y: itemModel.imageCurrentZoomScale)
        } else {
            imageView.transform = .identity
        }
    }
}
