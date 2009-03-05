class Rumld::Graph
  extend Forwardable
  attr_accessor :files, :doc_dir, :source_dirs

  def initialize(doc_dir, source_dirs = [], files = [])
    self.doc_dir = doc_dir
    self.source_dirs = source_dirs
    self.files = files
  end
  def_delegator :tree, :to_dot

  def files_to_process
    unless @files_to_process
      @files_to_process  = []
      source_dirs.each do |dir|
        files.each { |file| @files_to_process += Dir.glob(File.join(dir, '**', file)) } if files
      end
      @files_to_process.uniq!
      @files_to_process.each{|f| require f}
    end
    @files_to_process
  end

  def tree
    @tree ||= Rumld::Tree.new(self, defined_constant_names)
  end

  protected

  # Get a list of constants that RDoc says have been defined
  def defined_constant_names
    @defined_constant_names ||=
    files_to_process.collect do |filename|
      collect_possible_constant_names(constants_defined(File.readlines(filename))).select do |constant_name|
        File.exists?(Rumld::RDocInspector.doc_file_for(doc_dir, constant_name))
      end
    end.flatten
  end


  # This is a little on the ugly.  Psuedo-combinatorially collect the constants
  # You'll want to check the tests to see what I mean
  def collect_possible_constant_names(constant_names = [], prefix = nil)
    work = []
    constant_names.each_with_index do |c1, i|
      constant_name ="#{(prefix + '::') if prefix}#{c1}"
      work << constant_name
      work += collect_possible_constant_names(constant_names[(i+1)..-1], constant_name).flatten
    end
    work.uniq.sort
  end

  # This method makes no effort to properly establish the constant hierarchy
  # It just tries to determine the constants that are being defined
  def constants_defined(strings = [])
    constants = strings.grep(/^\W*(class|module)/).collect do |constant|
      constant.sub(/^\W*(class\W*<<|class|module)/, '').strip.sub(/\W\<.*/, '')
    end

    # only keeping constants
    constants.select do |c|
      c.match(/[A-Z]/)
    end
  end

end
