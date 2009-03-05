require File.join(File.dirname(__FILE__), 'test_helper')

class Rumld::TreeTest < Test::Unit::TestCase
  def setup
    @tree = Rumld::Tree.new(nil, [])
  end
  
  def test_doc_dir_is_delegated_graph
    @tree.expects(:graph).returns(stub('Graph', :doc_dir => :doc_dir))
    assert_equal :doc_dir, @tree.doc_dir
  end
  
  def test_build_nodes_with_multi_level_constant_names
    @tree = Rumld::Tree.new(nil, ['A', 'A::B', 'A::B::C'])
    assert_equal ['A'], @tree.nodes.collect{|n| n.constant_name}
  end

  def test_build_nodes_with_single_level_constant_names
    @tree = Rumld::Tree.new(nil, ['A', 'A::B'])
    assert_equal ['A'], @tree.nodes.collect{|n| n.constant_name}
  end
  
  def test_all_nodes
    @tree = Rumld::Tree.new(nil, ['A', 'A::B'])
    assert_equal ['A', 'A::B'], @tree.all_nodes.collect{|n| n.constant_name}
  end
  
  def test_node_for_should_return_a_node_that_matches_the_given_constant
    node = stub("Node", :constant => self.class)
    @tree.expects(:all_nodes).returns([node])
    assert_equal node, @tree.node_for(self.class)
  end

  def test_node_for_should_return_a_node_that_matches_the_given_constant_name
    node = stub("Node", :constant => self.class, :constant_name => "Awesome")
    @tree.expects(:all_nodes).returns([node])
    assert_equal node, @tree.node_for('Awesome')
  end
  
  def test_inheritence_edge_to_dot
    node = stub("Node", :inheritence_edge_to_dot => ['hello world'])
    @tree.expects(:all_nodes).returns([node])
    assert_equal 'hello world', @tree.send(:draw_inheritence_edges)
  end
  
  def test_to_dot_calls_draw_nodes_and_draw_included_modules
    @tree.expects(:draw_nodes).returns('Draw Nodes')
    @tree.expects(:draw_included_modules).returns('Draw Included Modules')
    @tree.expects(:draw_associations).returns('Draw Associations')
    @tree.expects(:draw_inheritence_edges).returns('Draw Inheritence Edges')
    assert_equal( %(digraph uml_diagram {
      graph[overlap=false, splines=true]
      Draw Nodes
      Draw Included Modules
      Draw Associations
      Draw Inheritence Edges
    }).no_whitespace, @tree.to_dot.no_whitespace)
  end
end
