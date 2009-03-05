require 'rake'
require 'rake/clean'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'rake/testtask'
require 'spec/rake/spectask'
require 'lib/rumld'

NAME = 'rumld'
VERS = '0.4.0'
RDOC_OPTS = ['--all', '--quiet', '--title', 'Ruby UML Diagrammer', '--main', 'README', '--inline-source']

desc "Does a full compile, test run"
task :default => [:test]

desc "Run all examples"
Spec::Rake::SpecTask.new('spec') do |t|
  t.spec_files = FileList['spec/**/*.rb']
end

Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'doc/rdoc'
  rdoc.options += RDOC_OPTS
  rdoc.main = "README"
  rdoc.rdoc_files.add ['README', 'CHANGELOG',  'lib/**/*.rb']
end

spec =
Gem::Specification.new do |s|
  s.name = NAME
  s.add_dependency('mocha', '>=0.5.2')
  s.add_dependency('activesupport', '>=1.3.1')
  s.add_dependency('hpricot', '>=0.6')
  s.bindir = 'bin'
  s.executables = ['rumld']
  
  s.version = VERS
  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true
  s.rdoc_options += RDOC_OPTS
  s.extra_rdoc_files = ["README", "CHANGELOG", "TODO"]
  s.summary = "A simple UML Grapher for Rails objects"
  s.description = s.summary
  s.author = "Jeremy Friesen"
  s.email = 'jeremyf@lightsky.com'
  s.homepage = 'http://www.lightsky.com/'

  s.files = %w(README Rakefile CHANGELOG TODO) +
  Dir.glob("{doc,test,lib,spec,bin}/**/*") +

  s.require_path = ["lib"]
end

Rake::GemPackageTask.new(spec) do |p|
  p.need_tar = true
  p.gem_spec = spec
end

desc "Run all the tests"
Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/**/*_test.rb']
  t.verbose = true
end


namespace :doc do
  desc "Generate documentation for the application"
  Rake::RDocTask.new("app") { |rdoc|
    rdoc.rdoc_dir = 'doc/'
    rdoc.title    = "Rails Application Documentation"
    rdoc.options << '--line-numbers'
    rdoc.rdoc_files.include('lib/rumld/**/*.rb')
  }

  task :graph => :reapp do

    Dir.glob(File.join(File.dirname(__FILE__), 'test', '**', '*.rb')).each do |f|
      require f
    end
    file_list = ARGV.grep(/^FILE(S)=/)
    files =
    if file_list.empty?
      ['*.rb']
    else
      file_list.pop.sub(/^FILE(S)=/, '').split(/(,\ )/).collect{|f| "#{f}#{'.rb' unless f.match(/\.rb$/)}"}
    end
    doc_folder = (ARGV.grep(/^DOC_DIR=(.*)/).pop.sub(/^DOC_DIR=/, '') rescue File.join(File.dirname(__FILE__), 'doc'))

    source_folder_list = ARGV.grep(/^SOURCE_DIR(S)=/)
    source_folders =
    if source_folder_list.empty?
      [File.join(File.dirname(__FILE__), 'lib' ), File.join(File.dirname(__FILE__), 'app', 'models' )]
    else
      source_folder_list.pop.sub(/^SOURCE_DIR(S)=/, '').split(/(,\ )/).collect{|f| "#{f}"}
    end

    File.open(File.join(File.dirname(__FILE__), 'my_graph.dot'), 'w') do |f|
      f.puts Rumld::Graph.new( doc_folder, source_folders , files ).to_dot
    end
  end
end
