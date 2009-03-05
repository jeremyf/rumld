class Rumld::RDocInspector

  class << self
    def doc_file_for(doc_dir, constant_name)
      File.join(doc_dir, 'classes', "#{constant_name.gsub('::', '/')}.html")
    end
  end

  XPATH_TO_METHOD_SECTION_HEADER = '#methods > h3'
  METHOD_HEADING_TABLE = {'Public Class methods' => :public_class,
    'Public Instance methods' => :public_instance,
    'Protected Instance methods' => :protected_instance,
    'Protected Class methods' => :protected_class
  }
  attr_reader :node, :constant_name
  def initialize(node, constant_name)
    @node = node
    @constant_name = constant_name
  end

  def doc
    @doc ||= open( doc_file_for ) {|f| Hpricot(f)}
  end

  def doc_file_for
    self.class.doc_file_for(node.doc_dir, constant_name)
  end

  def all_included_modules
    self.doc.search('#includes #includes-list .include-name').collect{|n| n.inner_text}
  end

  def doc_is_for_module?
    if @doc_is_for_module.nil?
      @doc_is_for_module =  (self.doc.search('#classHeader table.header-table tr td strong')[0].inner_html == 'Module')
    end
    @doc_is_for_module
  end

  # Given an RDoc class.html file, kick back a hash of methods
  def methods_by_section
    unless @methods_by_section
      @methods_by_section = {}
      (self.doc/XPATH_TO_METHOD_SECTION_HEADER).each do |method_section|
        if collector_key = METHOD_HEADING_TABLE[method_section.inner_html]
          @methods_by_section[collector_key] = find_methods_in_section(method_section)
        end
      end
    end
    @methods_by_section
  end

  def find_methods_in_section(method_section)
    collector = []
    # Oh why did method_section lose the following method?
    child = method_section.next_sibling
    while child && !child.css_path.include?(XPATH_TO_METHOD_SECTION_HEADER)
      # We got to a new section, so drop out of this silly non-sense
      break if child.css_path.include?(XPATH_TO_METHOD_SECTION_HEADER)
      (child/'.method-heading a').each do |signature|
        if string = signature.inner_text.strip.chomp
          collector << string
        end
      end
      child = child.next_sibling
    end
    collector.sort!
  end

end
