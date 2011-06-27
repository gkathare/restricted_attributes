require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'rake/testtask'


PKG_FILES = FileList[
  '[a-zA-Z]*',
  'generators/**/*',
  'lib/**/*',
  'test/**/*'
]
 
spec = Gem::Specification.new do |s|
  s.name = "restricted_attributes"
  s.version = "1.0.0"
  s.author = "Ganesh Kathare"
  s.email = "kathare.ganesh@gmail.com"
  s.homepage = "https://github.com/gkathare"
  s.platform = Gem::Platform::RUBY
  s.summary = "Sharing restricted_attributes"
  s.files = PKG_FILES.to_a
  s.require_path = "lib"
  s.has_rdoc = false
  s.extra_rdoc_files = ["README"]
  s.description = <<EOF
  This restricted_attributes plugin/gem provides the capabilities to restrict attributes(fields) 
  of db table's while add or update a record. It validate your attributes values before
  your validation stuff.
EOF
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end