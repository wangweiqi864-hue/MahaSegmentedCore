//
//  MahaSegmentedTitleOrImageItemModel.swift
//  MahaSegmentedView
//
//  Created by jiaxin on 2019/1/22.
//  Copyright © 2019 jiaxin. All rights reserved.
//

import UIKit

open class MahaSegmentedTitleOrImageItemModel: MahaSegmentedTitleItemModel {
    open var selectedImageInfo: String?
    open var loadImageClosure: MahaSegmentedLoadImageClosure?
    open var imageSize: CGSize = CGSize.zero
}
