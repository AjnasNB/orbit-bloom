require 'xcodeproj'
require 'fileutils'
def rooted_file(group, path)
  file = group.new_file(path)
  file.path = path
  file.source_tree = 'SOURCE_ROOT'
  file
end
root = File.expand_path('..', __dir__)
Dir.chdir(root)
project = Xcodeproj::Project.new('OrbitBloom.xcodeproj')
app = project.new_target(:application, 'OrbitBloom', :ios, '17.0')
app.product_name = 'OrbitBloom'
app.build_configurations.each do |config|
  s = config.build_settings
  s['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.orbitbloom.game'
  s['PRODUCT_NAME'] = 'OrbitBloom'
  s['SWIFT_VERSION'] = '5.0'
  s['TARGETED_DEVICE_FAMILY'] = '1,2'
  s['GENERATE_INFOPLIST_FILE'] = 'YES'
  s['INFOPLIST_KEY_CFBundleDisplayName'] = 'Orbit Bloom'
  s['INFOPLIST_KEY_UILaunchScreen_Generation'] = 'YES'
  s['INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone'] = 'UIInterfaceOrientationPortrait'
  s['INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad'] = 'UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight'
  s['INFOPLIST_KEY_ITSAppUsesNonExemptEncryption'] = 'NO'
  s['CODE_SIGN_STYLE'] = 'Automatic'
  s['MARKETING_VERSION'] = '1.0'
  s['DEVELOPMENT_TEAM'] = '4V29K5Q8S9'
  s['CURRENT_PROJECT_VERSION'] = '9'
  s['CODE_SIGN_ENTITLEMENTS'] = 'OrbitBloom/OrbitBloom.entitlements'
  s['ASSETCATALOG_COMPILER_APPICON_NAME'] = 'AppIcon'
end
source_group = project.main_group.new_group('OrbitBloom', 'OrbitBloom')
Dir.glob('OrbitBloom/**/*.swift').sort.each { |path| app.source_build_phase.add_file_reference(rooted_file(source_group, path)) }
resources = source_group.new_group('Resources')
Dir.glob('OrbitBloom/Resources/*').sort.each { |path| app.resources_build_phase.add_file_reference(rooted_file(resources, path)) }
package = project.new(Xcodeproj::Project::Object::XCLocalSwiftPackageReference)
package.relative_path = 'vendor/Match3Kit'
project.root_object.package_references << package
product = project.new(Xcodeproj::Project::Object::XCSwiftPackageProductDependency)
product.package = package
product.product_name = 'Match3Kit'
app.package_product_dependencies << product
framework_build_file = project.new(Xcodeproj::Project::Object::PBXBuildFile)
framework_build_file.product_ref = product
app.frameworks_build_phase.files << framework_build_file
tests = project.new_target(:unit_test_bundle, 'OrbitBloomTests', :ios, '17.0')
tests.add_dependency(app)
tests.build_configurations.each do |c|
  c.build_settings['SWIFT_VERSION'] = '5.0'
  c.build_settings['GENERATE_INFOPLIST_FILE'] = 'YES'
  c.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.orbitbloom.game.tests'
  c.build_settings['TEST_HOST'] = '$(BUILT_PRODUCTS_DIR)/OrbitBloom.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/OrbitBloom'
  c.build_settings['BUNDLE_LOADER'] = '$(TEST_HOST)'
end
test_group = project.main_group.new_group('Tests')
Dir.glob('OrbitBloomTests/iOS/*.swift').sort.each { |path| tests.source_build_phase.add_file_reference(rooted_file(test_group, path)) }
ui = project.new_target(:ui_test_bundle, 'OrbitBloomUITests', :ios, '17.0')
ui.add_dependency(app)
ui.build_configurations.each do |c|
  c.build_settings['SWIFT_VERSION'] = '5.0'
  c.build_settings['GENERATE_INFOPLIST_FILE'] = 'YES'
  c.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.orbitbloom.game.uitests'
  c.build_settings['TEST_TARGET_NAME'] = 'OrbitBloom'
end
Dir.glob('OrbitBloomUITests/*.swift').sort.each { |path| ui.source_build_phase.add_file_reference(rooted_file(test_group, path)) }
storekit = project.main_group.new_file('OrbitBloom.storekit')
tests.resources_build_phase.add_file_reference(storekit)
ui.resources_build_phase.add_file_reference(storekit)
project.save
scheme = Xcodeproj::XCScheme.new
scheme.add_build_target(app)
scheme.add_test_target(tests)
scheme.add_test_target(ui)
scheme.set_launch_target(app)
scheme.launch_action.xml_element.add_element('StoreKitConfigurationFileReference', {'identifier' => '../OrbitBloom.storekit'})
scheme.test_action.xml_element.add_element('StoreKitConfigurationFileReference', {'identifier' => '../OrbitBloom.storekit'})
scheme.save_as(project.path, 'OrbitBloom', true)
puts 'Generated OrbitBloom.xcodeproj'
