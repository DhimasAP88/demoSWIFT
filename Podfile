# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'
# Uncomment the next line to define a global platform for your project

# platform :ios, '9.0'
platform :ios, '10.0'


source 'https://github.com/CocoaPods/Specs.git'
use_frameworks!

def common_pods
    pod 'Alamofire', '~> 4.7'
    pod 'RxAlamofire', '~> 4.0'
    pod 'RxSwift', '~> 4.0'
    pod 'RxCocoa', '~> 4.0'
    pod 'SDWebImage', '~> 4.0'
end

target 'WheaterApp' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  common_pods

  # Pods for WheaterApp

  target 'WheaterAppTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'WheaterAppUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end
