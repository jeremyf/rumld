require 'ostruct'

module Rumld
  class OptionsStruct < OpenStruct

    require 'optparse'

    def initialize
      default_options = { :doc_dir => './doc',
        :files => RUMLD_DEFAULT_FILES,
        :outfile => './ruml.dot',
      :source_dirs => ['./lib', './app/models'] }
      super(default_options)
    end

    def parse(args)
      @opt_parser = OptionParser.new do |opts|
        opts.banner = "Usage: rumld [options]"
        opts.separator ""
        opts.separator "Options:"
        opts.on("-d", "--doc_dir ./ruml_doc", "Directory to generate rumld's", "working RDoc") do |value|
          self.doc_dir = value
        end

        opts.on("-o", "--outfile ruml.dot", "Output file") do |value|
          self.outfile = value
        end

        opts.on("-s", "--source_dirs lib,app/models", Array, "Directories for files") do |value|
          self.source_dirs = value
        end
        opts.on("-f", "--files file1[,fileN]", Array, "Files to graph", "defaults to #{RUMLD_DEFAULT_FILES.join(',')}") do |value|
          self.files = value
        end

      end

      begin
        @opt_parser.parse!(args)
      rescue OptionParser::AmbiguousOption
        option_error "Ambiguous option"
      rescue OptionParser::InvalidOption
        option_error "Invalid option"
      rescue OptionParser::InvalidArgument
        option_error "Invalid argument"
      rescue OptionParser::MissingArgument
        option_error "Missing argument"
      end
    end

    private

    def option_error(msg)
      STDERR.print "Error: #{msg}\n\n #{@opt_parser}\n"
      exit 1
    end

  end
end
