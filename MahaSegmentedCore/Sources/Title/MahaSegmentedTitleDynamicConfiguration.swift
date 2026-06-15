//
//  MahaSegmentedTitleBaseDataSource.swift
//  MahaSegmentedView
//
//  Created by Jiaxin Pu on 2025/4/16.
//  Copyright © 2024 jiaxin. All rights reserved.
//

import UIKit

public protocol MahaSegmentedTitleDynamicConfiguration: NSObject {
    func titleNumberOfLines(at index: Int) -> Int
    func titleNormalColor(at index: Int) -> UIColor
    func titleSelectedColor(at index: Int) -> UIColor
    func titleNormalFont(at index: Int) -> UIFont
    func titleSelectedFont(at index: Int) -> UIFont?
}
