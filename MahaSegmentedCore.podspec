
Pod::Spec.new do |s|
  s.name                  = "MahaSegmentedCore"
  s.version               = "0.1.0"
  s.summary               = "A private segmented view component used by the app."

  s.description           = <<-DESC
                              MahaSegmentedCore repackages the existing JXSegmentedView implementation
                              into a private pod and exposes renamed public APIs for the app.
                              DESC

  s.homepage              = "https://github.com/wangweiqi864-hue/MahaSegmentedCore"
  s.license               = { :type => "MIT", :file => "LICENSE" }
  s.author                = { "wangweiqi864-hue" => "wangweiqi864-hue@users.noreply.github.com" }
  s.source                = { :git => "ssh://git@github.com/wangweiqi864-hue/MahaSegmentedCore.git", :tag => s.version.to_s }

  s.ios.deployment_target = "13.0"

  s.swift_versions        = ["5.0", "5.1", "5.2"]
  s.requires_arc          = true
  s.frameworks            = "UIKit"
  s.source_files          = "MahaSegmentedCore/Sources/**/*.{swift}"
  s.resource_bundles = { "MahaSegmentedCore_Privacy" => ["MahaSegmentedCore/Sources/PrivacyInfo.xcprivacy"] }
end
