require File.join(File.dirname(__FILE__), 'test_helper')

class Rumld::GraphTest < Test::Unit::TestCase

  def test_to_dot_delegates_to_tree
    obj = Rumld::Graph.new('', [],[])
    obj.expects(:tree).returns(stub('Tree', :to_dot => :to_dot))
    assert_equal :to_dot, obj.to_dot
  end

  def test_collect_possible_constant_names
    assert_equal ["A", "A::B", "A::B::C", "A::B::C::D", "A::B::D", "A::C", "A::C::D", "A::D",
     "B", "B::C", "B::C::D", "B::D",
     "C", "C::D",
     "D"], Rumld::Graph.new(nil, nil, nil).send(:collect_possible_constant_names, ['A', 'B', 'C', 'D'])
  end

  def test_constants_defined
    file = <<-EOV
    class One
      class Two::Three < One
        include Eight
        extend Nine
        def function(one)
        end
      end
      module Four
      end
      class << self
      end

      class << Five
      end
    end
    EOV
    assert_equal( ['One', 'Two::Three', 'Four', 'Five'], Rumld::Graph.new(nil, nil, nil).send(:constants_defined, file.split("\n")))
  end
  
  def test_files_to_process_should_use_the_files
    grapher = Rumld::Graph.new(nil, [File.dirname(__FILE__),File.dirname(__FILE__)], [File.basename(__FILE__)])
    assert_equal [__FILE__], grapher.send(:files_to_process)
  end
  
end
