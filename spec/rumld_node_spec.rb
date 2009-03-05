require File.join(File.dirname(__FILE__), 'spec_helper')

module Rumld
  describe 'Node' do
    before(:each) do
      @node = Rumld::Node.new(stub('tree', :doc_dir => '/chicken/noodle'), 'Rumld::Node')
    end

    it 'to_dot for belongs_to relation is blank when there association is empty' do
      assoc = stub('Assoc', :options => {})
      @node.send(:to_dot_for_belongs_to, assoc).should be_empty
    end

    it 'have an empty active record associations if the object does not have associations' do
      @node.send(:active_record_associations).should == []
    end

    it 'active record associations reflect on all associations when available' do
      @node.send(:constant).expects(:reflect_on_all_associations).returns(['One'])
      @node.send(:active_record_associations).should == ['One']
    end

    it 'uses constant name to derive the constant' do
      @node.send(:constant).should == Rumld::Node
    end

    it 'uses the intersect of rdoc_insepctors all included modules and trees constant names to determine included modules' do
      @node.tree.expects(:constant_names).returns(['A', 'C', 'A::D'])
      @node.stubs(:rdoc_inspector).returns(stub('RDocInspector', :all_included_modules => ['A', 'B'] ))
      @node.included_modules.should == ['A']
    end

    it 'converts included_modules to_dot' do
      @node.expects(:included_modules).returns(['NPR', 'Radio'])
      @node.included_modules_to_dot.should == ['"Rumld::Node" -> "NPR" [style=dotted, arrowhead=empty]', '"Rumld::Node" -> "Radio" [style=dotted, arrowhead=empty]']
    end

    it 'should use self_to_dot in node_to_dot if there are no children' do
      @node.expects(:self_to_dot).returns('No Children')
      @node.expects(:children?).returns(false)
      @node.node_to_dot.should == 'No Children'
    end

    it 'should use self_to_dot and children node_to_dot if there are children' do
      child = Rumld::Node.new(@node.tree, "#{@node.constant_name}::Considered")
      @node.expects(:self_to_dot).returns('Children')
      child.expects(:self_to_dot).returns('I am a child')
      @node.children << child

      @node.node_to_dot.no_whitespace.should match(/#{Regexp.escape(%(subgraphclusterNode{label="Node))}/ )

    end

    it 'should have a self_and_descendants' do
      child = Rumld::Node.new(@node.tree, "#{@node.constant_name}::Considered")
      child.expects(:self_and_descendants).returns([child]).at_least(1)
      @node.children << child
      @node.self_and_descendants.should == [@node, child] 
    end
    
    it 'by default it should have no children' do
      @node.children.should == []
      @node.children?.should == false
    end
    
    it 'should not be a parent of a constant at the same level in the module tree' do
      @node = Rumld::Node.new(stub('tree', :doc_dir => '/chicken/noodle'), 'Object')
      @node.should_be_parent_of?('Rumld').should be_false
    end
    
    it 'should be a parent of a constant one level deeper in the module tree' do
      @node.should_be_parent_of?("#{@node.constant_name}::Considered").should be_true
    end

    it 'should not be a parent of itself' do
      @node.should_be_parent_of?("#{@node.constant_name}").should be_false
    end

    it 'should not be a parent of a constant in the wrong module space' do
      @node.should_be_parent_of?("Piggly::#{@node.constant_name}::Considered").should be_false
    end

    it 'should not be a parent of a constant two levels deeper than itself' do
      @node.should_be_parent_of?("#{@node.constant_name}::Considered::Modules").should be_false
    end
    
    it 'doc_dir is delegated to underlying tree' do
      @node.tree.doc_dir.should == @node.doc_dir 
    end
    
    it 'constant_is_module is delegated to the underlying rdoc_inspector' do
      @node.expects(:rdoc_inspector).returns(stub('RDocInspector', :doc_is_for_module? => true))
      @node.constant_is_module?.should be_true
    end
    
    it 'methods_by_section is delegated to undelrying rdoc_inspector' do
      @node.expects(:rdoc_inspector).returns(stub('RDocInspector', :methods_by_section => {}))
      @node.methods_by_section.should == {}
    end
  end
end
