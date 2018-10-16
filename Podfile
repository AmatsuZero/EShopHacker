# Uncomment the next line to define a global platform for your project
inhibit_all_warnings!
use_frameworks!

def shared_pods
    pod 'Alamofire', '~> 4.7'
    pod 'RxSwift',    '~> 4.0'
    pod 'RxCocoa',    '~> 4.0'
    pod 'RxAlamofire'
    pod 'SWXMLHash', '~> 4.0.0'
    pod 'SwiftyJSON', '~> 4.0'
    pod 'GDGeoData', '~> 0.1'
end

def shared_test_pods
    pod 'RxBlocking', '~> 4.0'
    pod 'RxTest',     '~> 4.0'
end

abstract_target 'mac' do
    platform :osx, '10.10'
    target 'EShopHacker' do
        shared_pods
        
        target 'EShopHackerTests' do
            inherit! :search_paths
            shared_test_pods
        end
    end
end

abstract_target 'ios' do
    platform :ios, '9.0'
    target 'EShopHelper' do
        shared_pods
        pod 'Material', '~> 2.0'
        pod 'SnapKit', '~> 4.0.0'
        
        target 'EShopHelperTests' do
            inherit! :search_paths
            shared_test_pods
        end
   end
end
