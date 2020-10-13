# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

target 'SafeTravels' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for SafeTravels
  pod 'Firebase/Auth'
  pod 'Firebase/Analytics'
  pod 'Firebase/Firestore'
  pod 'GoogleSignIn'
  pod 'FirebaseUI'
  pod 'FirebaseFirestoreSwift'
  pod 'SearchTextField'

  target 'SafeTravelsTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'SafeTravelsUITests' do
    # Pods for testing
  end
  
  post_install do |pi|
    pi.pods_project.targets.each do |t|
      t.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.0'
      end
    end
  end
end
