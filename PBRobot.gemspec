# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'PBRobot/version'

Gem::Specification.new do |s|
  s.name        = 'PBRobot'
  s.version     = PBRobot::VERSION
  s.summary     = "HIT Pinboard backend crawling framework"
  s.description = "A simple crawling framework based on Mechanize and Nokogiri"
  s.authors     = ["Austin Chou"]
  s.email       = 'austinchou0126@gmail.com'
  s.homepage    = "https://github.com/HIT-Pinboard/Crawl-Robots"
  s.license       = 'MIT'

  s.files         = `git ls-files -z`.split("\x0")
  s.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]

  s.add_runtime_dependency 'mechanize'
  s.add_runtime_dependency 'nokogiri'
end