require File.join(File.dirname(__FILE__), 'test_helper')

class Rumld::NodeTest < Test::Unit::TestCase
  def setup
    @node = Rumld::Node.new(stub('tree', :doc_dir => '/chicken/noodle'), 'Rumld::NodeTest')
  end

  def test_to_dot_for_belongs_to_should_blank
    assoc = stub('Assoc', :options => {})
    assert @node.send(:to_dot_for_belongs_to, assoc).empty?
  end


  def test_reflect_on_all_associations_without_an_active_record_object
    @node = Rumld::Node.new(stub('tree', :doc_dir => '/chicken/noodle'), 'Rumld::Node')
    assert_equal [], @node.send(:active_record_associations)
  end

  def test_reflect_on_all_associations_without_an_active_record_object
    @node = Rumld::Node.new(stub('tree', :doc_dir => '/chicken/noodle'), 'Rumld::Node')
    @node.send(:constant).expects(:reflect_on_all_associations).returns(['One'])
    assert_equal ['One'], @node.send(:active_record_associations)
  end

  def test_constant
    assert_equal Rumld::Node, Rumld::Node.new(stub('tree', :doc_dir => '/chicken/noodle'), 'Rumld::Node').send(:constant)
  end

  def test_active_record_associations
    assert_equal Rumld::Node, Rumld::Node.new(stub('tree', :doc_dir => '/chicken/noodle'), 'Rumld::Node').send(:constant)
  end

  def test_included_modules_should_be_the_intersect_of_all_included_modules_and_rdocced_modules
    @node.tree.expects(:constant_names).returns(['A', 'C', 'A::D'])
    @node.stubs(:rdoc_inspector).returns(stub('RDocInspector', :all_included_modules => ['A', 'B'] ))
    assert_equal ['A'], @node.included_modules
  end
  
  def test_included_modules_to_dot
    @node.expects(:included_modules).returns(['NPR', 'Radio'])
    assert_equal( ['"Rumld::NodeTest" -> "NPR" [style=dotted, arrowhead=empty]', '"Rumld::NodeTest" -> "Radio" [style=dotted, arrowhead=empty]'], @node.included_modules_to_dot)
  end

  def test_node_to_dot_without_children
    @node.expects(:self_to_dot).returns('No Children')
    @node.expects(:children?).returns(false)
    assert_equal 'No Children', @node.node_to_dot
  end

  def test_node_to_dot_with_children
    child = Rumld::Node.new(@node.tree, "#{@node.constant_name}::Considered")
    @node.expects(:self_to_dot).returns('Children')
    child.expects(:self_to_dot).returns('I am a child')
    @node.children << child

    assert_match( /#{Regexp.escape(%(subgraphclusterNodeTest{label="NodeTest))}/, @node.node_to_dot.no_whitespace)
  end
  
  def test_self_and_descendants
    child = Rumld::Node.new(@node.tree, "#{@node.constant_name}::Considered")
    child.expects(:self_and_descendants).returns([child]).at_least(1)
    @node.children << child
    assert_equal [@node, child], @node.self_and_descendants
  end
  
  def test_children_should_default_to_an_array
    assert_equal [], @node.children
  end

  def test_children_empty_means_false_for_children?
    assert ! @node.children?
  end

  def test_children_not_empty_means_true_for_children?
    @node.children << 'Hello'
    assert @node.children?
  end
  
  def test_constants_should_be_parent_of_regression_prevention_1
    @node = Rumld::Node.new(stub('tree', :doc_dir => '/chicken/noodle'), 'Object')
    assert ! @node.should_be_parent_of?('Rumld')
  end
  
  def test_constants_one_module_level_deeper_should_be_child_of_node
    assert @node.should_be_parent_of?('Rumld::NodeTest::Considered')
  end

  def test_constants_should_not_be_parents_of_themselves
    assert ! @node.should_be_parent_of?('Rumld::NodeTest')
  end

  def test_constants_in_wrong_module_space_should_not_be_child_of_node
    assert ! @node.should_be_parent_of?('This::Is::Rumld::NodeTest')
  end

  def test_constants_one_module_level_deeper_in_wrong_module_space_should_not_be_child_of_node
    assert ! @node.should_be_parent_of?('This::Is::Rumld::NodeTest::Considered')
  end

  def test_constants_two_module_level_deeper_should_be_child_of_node
    assert ! @node.should_be_parent_of?('Rumld::NodeTest::Considered::On')
  end
  
  def test_doc_dir_is_delegated_to_nodes_tree
    assert_equal @node.tree.doc_dir, @node.doc_dir
  end
  
  def test_constant_is_module_is_delegated_to_rdoc_inspector_doc_is_for_module
    @node.expects(:rdoc_inspector).returns(stub('RDocInspector', :doc_is_for_module? => true))
    assert_equal true, @node.constant_is_module?
  end
  
  def test_methods_by_section_is_delegated_to_rdoc_inspector
    @node.expects(:rdoc_inspector).returns(stub('RDocInspector', :methods_by_section => {}))
    assert_equal( {}, @node.methods_by_section )
  end
  
  def test_format_methods_should_replace_block_bracketes
    assert_equal "function(self = \\{ :page =\\> 1\\}) \\{ \\|self\\| ... \\}\\l", @node.send(:format_methods, ["function(self = { :page => 1}) { |self| ... }"])
  end
end