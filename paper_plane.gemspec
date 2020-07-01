
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'paper_plane/version'

Gem::Specification.new do |spec|
  spec.name          = 'paper_plane'
  spec.version       = PaperPlane::VERSION
  spec.authors       = ['Guilherme Andrade']
  spec.email         = ['guilherme.andrade.ao@gmail.com']

  spec.summary       = 'A featherweight library for multi thread message deliveries.'
  spec.description   = 'A featherweight library for multi thread message deliveries.'
  spec.homepage      = 'https://github.com/guilherme-andrade/paper_plane'
  spec.license       = 'MIT'

  if spec.respond_to?(:metadata)
    spec.metadata['homepage_uri'] = spec.homepage
    spec.metadata['source_code_uri'] = 'https://github.com/guilherme-andrade/paper_plane'
    spec.metadata['changelog_uri'] = 'https://github.com/guilherme-andrade/paper_plane/blob/master/Changelog.md'
  else
    raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  end

  spec.files = Dir['lib/**/*', 'Changelog.md', 'README.md']
  spec.bindir        = 'exe'
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport', '~> 6.0', '>= 6.0.3'
  spec.add_dependency 'actionmailer', '~> 6.0', '>= 6.0.3'
  spec.add_dependency 'activejob', '~> 6.0', '>= 6.0.3'
  spec.add_dependency 'twilio-ruby', '~> 5.27', '>= 5.27.1'
  spec.add_dependency 'objectified', '~> 0.1.3', '>= 0.1.3'
  spec.add_dependency 'railties', '~> 6.0', '>= 6.0.3'
end
