class Rumld::Node
  extend Forwardable
  attr_reader :constant_name, :tree, :constant

  def_delegator :tree, :doc_dir
  def_delegator :rdoc_inspector, :doc_is_for_module?, :constant_is_module?
  def_delegator :rdoc_inspector, :methods_by_section
  def_delegator :rdoc_inspector, :doc_file_for

  def initialize(tree, constant_name)
    @constant_name = constant_name
    @tree = tree
  end

  def constant
    @constant ||= constant_name.constantize
  end

  def node_to_dot
    if children?
      children.sort!{|a,b| a.constant_name <=> b.constant_name}
      %(subgraph cluster#{detached_constant_name} {
        label = "#{detached_constant_name}";
        color = grey;
        #{self_to_dot(:style=>"dotted")}
        #{children.collect{|n| n.node_to_dot}.join("\n")}
      })
    else
      self_to_dot
    end
  end

  def inheritence_edge_to_dot
    if constant.respond_to?(:superclass) && ancestor_node = tree.node_for(constant.superclass)
      %("#{constant_name}" -> "#{ancestor_node.constant_name}" [arrowhead=empty])
    end
  end

  def included_associations_to_dot
    active_record_associations.collect do |assoc|
      case assoc.macro.to_s
      when 'belongs_to'               then to_dot_for_belongs_to(assoc)
      when 'has_one'                  then has_one_to_dot(assoc)
      when 'has_many'                 then has_many_to_dot(assoc)
      when 'has_and_belongs_to_many'  then habtm_to_dot(assoc)
      end
    end
  end

  def included_modules_to_dot
    included_modules.collect do |mod|
      %("#{constant_name}" -> "#{mod}" [style=dotted, arrowhead=empty])
    end
  end

  def self_and_descendants
    ([self] + children.collect{|n| n.self_and_descendants}).flatten
  end

  def children
    @children ||= []
  end

  def children?
    !children.empty?
  end

  def included_modules
    rdoc_inspector.all_included_modules & tree.constant_names
  end

  # I only want constants that are one module level
  # deeper than the current constant_name
  def should_be_parent_of?(other_constant_name)
    if match = other_constant_name.match(/^#{Regexp.escape(constant_name + '::')}/)
      %(#{match}#{other_constant_name.split('::').last}) == other_constant_name
    else
      false
    end
  end

  protected

  # We can skip this one because, for now its un-needed
  def to_dot_for_belongs_to(assoc)
    if assoc.options[:polymorphic]
      %(
      "#{assoc.class_name}" [shape = "record"]
      "#{constant_name}" -> "#{assoc.class_name}" [headlabel="*", taillabel="1"]
      )
    else
      ''
    end
  end

  def has_one_to_dot(assoc)
    if assoc.options[:as]
      %("#{constant_name}" -> "#{assoc.options[:as].to_s.classify}" [arrowhead=empty, style=dotted, label="by :#{assoc.name}"])
    elsif tree.constant_names.include?(assoc.class_name)
      %("#{constant_name}" -> "#{assoc.class_name}" [headlabel="1", taillabel="1"])
    else
      ''
    end
  end

  def has_many_to_dot(assoc)
    if assoc.options[:as]
      %("#{constant_name}" -> "#{assoc.options[:as].to_s.classify}" [arrowhead=empty, style=dotted, label="by :#{assoc.name}"])
    elsif tree.constant_names.include?(assoc.class_name)
      %("#{constant_name}" -> "#{assoc.class_name}" [headlabel="1", taillabel="*"])
    else
      ''
    end
  end

  def habtm_to_dot(assoc)
    ''
  end

  def active_record_associations
    constant.respond_to?(:reflect_on_all_associations) ? constant.reflect_on_all_associations : []
  end

  def self_to_dot(options = {})
    default_options = { :shape => "record", :label => "{#{dot_formatted_node_header}||#{format_methods(methods_by_section[:public_class], '.')}#{format_methods(methods_by_section[:public_instance], '#')}}"}
    options = default_options.merge(options)
  %("#{constant_name}" [#{options.collect{|key, value| key.to_s + '="' + value.to_s + '"'}.join(', ') }] )
end

def detached_constant_name
  constant_name.split('::').last
end

def rdoc_inspector
  @rdoc_inspector ||= Rumld::RDocInspector.new( self, constant_name )
end

# Add a << module >> to the doc if its a Module
def dot_formatted_node_header
  "#{'\\<\\< module \\>\\>\\l' if constant_is_module?}#{detached_constant_name}"
end

def format_methods(methods = [], prefix = '')
  if (methods && !methods.empty?)
    methods.collect do |method| 
      prefix.to_s + method.gsub(/([{}>\|])/){|match| "\\#{match.to_s}"}
    end.join('\\l') + '\\l'
  end
end

end
