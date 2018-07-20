# Uncomment the next line to define a global platform for your project
platform :osx, '10.10'

inhibit_all_warnings!

target 'EShopHacker' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  pod 'Alamofire', '~> 4.7'
  pod 'RxSwift',    '~> 4.0'
  pod 'RxCocoa',    '~> 4.0'
  pod 'RxAlamofire'
  pod 'SWXMLHash', '~> 4.0.0'
  pod 'SwiftyJSON', '~> 4.0'

  target 'EShopHackerTests' do
    inherit! :search_paths
    pod 'RxBlocking', '~> 4.0'
    pod 'RxTest',     '~> 4.0'
  end

end
