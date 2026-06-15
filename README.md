## MahaSegmentedCore

`MahaSegmentedCore` is a private segmented view component used by the app.

This package keeps the existing segmented-view behavior while exposing the private `MahaSegmented*` API names required by the app migration.

## Requirements

- iOS 13.0+
- Swift 5.x

## Installation

```ruby
pod 'MahaSegmentedCore', '0.1.0'
```

## Main Public APIs

- `MahaSegmentedView`
- `MahaSegmentedViewDelegate`
- `MahaSegmentedViewDataSource`
- `MahaSegmentedListContainerView`
- `MahaSegmentedListContainerViewDataSource`
- `MahaSegmentedListContainerViewListDelegate`
- `MahaSegmentedTitleDataSource`
- `MahaSegmentedIndicatorLineView`
- `MahaSegmentedLoadImageClosure`

## Notes

- The library does not depend on app routing, theme, dark mode, localization, or business `MH*` code.
- The package is intended for private CocoaPods distribution and app integration.
