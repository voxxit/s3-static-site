# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.authors       = ["Josh Delsman"]
  gem.email         = ["jdelsman@voxxit.com"]
  gem.description   = "Using Ruby and Capistrano, build and deploy a static website to Amazon S3"
  gem.summary       = "Using Ruby and Capistrano, build and deploy a static website to Amazon S3"
  gem.homepage      = "http://github.com/voxxit/s3-static-site"
  gem.licenses      = ["MIT"]
  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "s3-static-site"
  gem.require_paths = ["lib"]
  gem.version       = "0.3.0"

  # Gem dependencies
  gem.add_dependency("aws-sdk", '~> 1.0', '>= 1.12.0')
  gem.add_dependency("capistrano")
  gem.add_dependency("haml")
  gem.add_dependency("mime-types")
end
