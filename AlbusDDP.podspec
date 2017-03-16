Pod::Spec.new do |spec|
  spec.name = "AlbusDDP"
  spec.version = "1.0.1"
  spec.summary = "DDP Collection/Document"
  spec.homepage = "https://github.com/CleanioInc/AlbusDDP"
  spec.license = { type: 'MIT', file: 'LICENSE' }
  spec.authors = { "Guillaume Elloy" => 'guillaume@getcleanio.com' }

  spec.platform = :ios, "8.0"
  spec.requires_arc = true
  spec.source = { git: "https://github.com/CleanioInc/AlbusDDP", tag: "v#{spec.version}", submodules: true }
  spec.source_files = "AlbusDDP/**/*.{h,swift}"

  spec.dependency "meteor-ios"
  spec.dependency "ObjectMapper"
end
