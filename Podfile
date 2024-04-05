# platform :ios, '9.0'

target 'Vendour' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks

  use_frameworks!

  # Pods for Vendour
  pod 'SwiftyJSON'
  pod 'SkyFloatingLabelTextField'
  pod 'SWRevealViewController'
  pod 'GoogleMaps'
  pod 'GooglePlaces'
  pod 'SDWebImage'
  pod 'Alamofire'
  pod 'SkyFloatingLabelTextField'
  pod 'IQKeyboardManagerSwift'
  pod 'SVProgressHUD'
  pod 'FTIndicator'
  pod 'SDWebImage'
  pod 'IQKeyboardManagerSwift'
  pod 'SimplOneClick'
  pod 'razorpay-pod', '1.0.28'
  pod 'SimplOneClick'
  pod 'Fabric'
  pod 'Crashlytics'
  pod 'Firebase'
    post_install do |installer|
     installer.pods_project.build_configurations.each do |config|
         config.build_settings.delete('CODE_SIGNING_ALLOWED')
         config.build_settings.delete('CODE_SIGNING_REQUIRED')
     end
   end
  target 'VendourTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'VendourUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end
