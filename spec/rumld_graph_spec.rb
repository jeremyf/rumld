require File.join(File.dirname(__FILE__), 'spec_helper')

module Rumld
  describe Graph do
    before(:each) do
      @graph = Rumld::Graph.new
    end
    it 'delegates to_dot to tree' do
      @graph.expects(:tree).returns(stub('Tree', :to_dot => :to_dot))
      @graph.to_dot.should == :to_dot
    end
    
    it 'collects possible constant names should recursively build a larger constant list' do
      @graph.send(:collect_possible_constant_names, ['One', 'Two::A', 'Three']).should == ['One', 'One::Two::A', 'One::Two::A::Three', 'Three', 'Two::A', 'Two::A::Three']
    end
    
    it 'collects all of the demodulized constants that are declared' do
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
       @graph.send(:constants_defined, file.split("\n")).should == ['One', 'Two::Three', 'Four', 'Five']
    end
    
    it 'uniquely determines all the matching files to process' do
      @graph = Rumld::Graph.new(nil, [File.dirname(__FILE__),File.dirname(__FILE__)], [File.basename(__FILE__)])
      @graph.send(:files_to_process).should == [__FILE__]
    end
  end
end
