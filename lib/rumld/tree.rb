class Rumld::Tree
  extend Forwardable
  def_delegator :graph, :doc_dir
  attr_reader :constant_names, :graph
  def initialize( graph, constant_names = [])
    @graph = graph
    @constant_names = constant_names.uniq.sort
    build_nodes
  end
  
  def to_dot
    %(digraph uml_diagram {\n  graph[rotate=landscape, ratio=fill, overlap=false, splines=true]
      #{draw_nodes}
      #{draw_included_modules}
      #{draw_associations}
      #{draw_inheritence_edges}
    }
    )
  end
  
  def nodes
    @nodes ||= []
  end
  
  def all_nodes
    nodes.collect{|n| n.self_and_descendants}.flatten
  end  
  
  def node_for( constant )
    all_nodes.detect{|node| node.constant == constant || node.constant_name == constant}
  end
  
  protected
  
  def draw_inheritence_edges
    all_nodes.collect{|n| n.inheritence_edge_to_dot}.flatten.join("\n")
  end
  
  def draw_nodes
    nodes.collect{|n| n.node_to_dot}.flatten.join("\n")
  end
  
  def draw_associations
    all_nodes.collect{|n| n.included_associations_to_dot}.flatten.join("\n")
  end
  
  def draw_included_modules
    all_nodes.collect{|n| n.included_modules_to_dot}.flatten.join("\n")
  end
  
  def build_nodes
    constant_names.each do |constant_name|
      if node = all_nodes.detect{|node| node.should_be_parent_of?(constant_name)}
        node.children << Rumld::Node.new(self, constant_name)
      else
        nodes << Rumld::Node.new(self, constant_name)
      end
    end
    nodes.sort!{|a,b| a.constant_name <=> b.constant_name}
  end  
  
end