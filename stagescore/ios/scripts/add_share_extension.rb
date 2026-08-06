#!/usr/bin/env ruby
# Adds ShareExtension target for share_handler (Spec 0029). Idempotent.
require 'xcodeproj'

PROJECT_PATH = File.expand_path('../Runner.xcodeproj', __dir__)
GROUP_ID = 'group.com.backingscore.scoreapp'
BUNDLE_ID = 'com.backingscore.scoreapp.ShareExtension'

project = Xcodeproj::Project.open(PROJECT_PATH)

if project.targets.any? { |t| t.name == 'ShareExtension' }
  puts 'ShareExtension target already exists — skipping.'
  exit 0
end

runner = project.targets.find { |t| t.name == 'Runner' }
raise 'Runner target not found' unless runner

# Ensure CODE_SIGN_ENTITLEMENTS on Runner
runner.build_configurations.each do |config|
  config.build_settings['CODE_SIGN_ENTITLEMENTS'] = 'Runner/Runner.entitlements'
  config.build_settings['CUSTOM_GROUP_ID'] = GROUP_ID
end

ext = project.new_target(
  :app_extension,
  'ShareExtension',
  :ios,
  '15.0'
)

# File references
share_group = project.main_group.find_subpath('ShareExtension', true)
share_group.set_source_tree('<group>')
share_group.set_path('ShareExtension')

swift = share_group.new_file('ShareViewController.swift')
plist = share_group.new_file('Info.plist')
entitlements = share_group.new_file('ShareExtension.entitlements')
storyboard_group = share_group.find_subpath('Base.lproj', true)
storyboard_group.set_source_tree('<group>')
storyboard_group.set_path('Base.lproj')
storyboard = storyboard_group.new_file('MainInterface.storyboard')

ext.add_file_references([swift, storyboard])
ext.build_configurations.each do |config|
  config.build_settings.merge!(
    'CODE_SIGN_ENTITLEMENTS' => 'ShareExtension/ShareExtension.entitlements',
    'CUSTOM_GROUP_ID' => GROUP_ID,
    'INFOPLIST_FILE' => 'ShareExtension/Info.plist',
    'GENERATE_INFOPLIST_FILE' => 'NO',
    'PRODUCT_NAME' => 'ShareExtension',
    'PRODUCT_BUNDLE_IDENTIFIER' => BUNDLE_ID,
    'WRAPPER_EXTENSION' => 'appex',
    'SKIP_INSTALL' => 'YES',
    'SWIFT_VERSION' => '5.0',
    'MARKETING_VERSION' => '0.1.0',
    'CURRENT_PROJECT_VERSION' => '1',
    'TARGETED_DEVICE_FAMILY' => '1,2',
    'LD_RUNPATH_SEARCH_PATHS' => '$(inherited) @executable_path/Frameworks @executable_path/../../Frameworks',
  )
end

# Embed appex in Runner
embed = runner.copy_files_build_phases.find { |p| p.name == 'Embed App Extensions' }
unless embed
  embed = project.new(Xcodeproj::Project::Object::PBXCopyFilesBuildPhase)
  embed.name = 'Embed App Extensions'
  embed.dst_subfolder_spec = Xcodeproj::Constants::COPY_FILES_BUILD_PHASE_DESTINATIONS[:plug_ins]
  runner.build_phases << embed
end
embed.add_file_reference(ext.product_reference)
embed.files.each do |bf|
  next unless bf.file_ref == ext.product_reference
  bf.settings = { 'ATTRIBUTES' => ['RemoveHeadersOnCopy'] }
end

# Dependency
runner.add_dependency(ext)

# Flutter Thin Binary input on Info.plist + Embed App Extension creates an
# Xcode dependency cycle — clear Thin Binary I/O and put Embed last.
thin = runner.build_phases.find do |p|
  p.isa == 'PBXShellScriptBuildPhase' && p.name.to_s == 'Thin Binary'
end
if thin
  thin.input_paths = []
  thin.output_paths = []
  thin.always_out_of_date = '1' if thin.respond_to?(:always_out_of_date=)
end
embed_phase = runner.build_phases.find do |p|
  p.isa == 'PBXCopyFilesBuildPhase' && p.display_name.to_s.include?('Embed App Extensions')
end
if embed_phase
  runner.build_phases.delete(embed_phase)
  runner.build_phases << embed_phase
end

project.save
puts 'Added ShareExtension target to Runner.xcodeproj'
