require File.join(File.dirname(__FILE__), 'spec_helper')

#class Rumld::RDocInspectorTest < Test::Unit::TestCase
#
#  def setup_rdoc
#    `rdoc #{File.dirname(__FILE__).gsub(' ', '\\ ')}`
#  end
#
#  def teardown
#    `rm -rf #{File.join(File.dirname(__FILE__), 'doc').gsub(' ', '\\ ')}`
#  end
#
#  def setup
#    @node = stub('Node', :constant_name => 'Rumld::RDocInspector', :doc_dir => File.join(File.dirname(__FILE__), '..', 'doc'))
#    @constant_name = 'Rumld::RdocInspectorTest'
#    @rdoc_inspector = Rumld::RDocInspector.new(@node, @constant_name)
#  end
#
#  def test_doc_file_for
#    assert_equal 'hello/world/classes/How/Are/You.html', Rumld::RDocInspector.doc_file_for('hello/world', 'How::Are::You')
#  end
#
#  def test_all_included_modules
#    string = %(
#    <html><body><div id="includes">
#          <h3 class="section-bar">Included Modules</h3>
#
#          <div id="includes-list">
#            <span class="include-name">Two::Towers</span>
#            <span class="include-name"><a href="AccountModel/AccountImport.html">AccountModel::AccountImport</a></span>
#          </div>
#        </div></body></html>
#    )
#    @rdoc_inspector.expects(:doc).returns(Hpricot( string ))
#    assert_equal ['Two::Towers', 'AccountModel::AccountImport'], @rdoc_inspector.all_included_modules
#  end
#
#  def test_all_included_modules_should_be_empty_when_no_matching_elements
#    string = %(
#    <html><body>
#        </body></html>
#    )
#    @rdoc_inspector.expects(:doc).returns(Hpricot( string ))
#    assert_equal [], @rdoc_inspector.all_included_modules
#  end
#  
#  def test_doc_is_for_module_when_given_a_module_that_has_been_rdoced
#    string = '<html><body><div id="classHeader">
#    <table class="header-table">
#    <tr class="top-aligned-row">
#    <td><strong>Module</strong></td>
#    <td class="class-name-in-header">Rumld::Grapher</td>
#    </tr>
#    </table>
#    </div></body></html>'
#    @rdoc_inspector.expects(:doc).returns(Hpricot( string ))
#    assert @rdoc_inspector.doc_is_for_module?
#  end
#
#  def test_doc_is_for_module_when_given_a_class_that_has_been_rdoced
#    string = '<html><body><div id="classHeader">
#    <table class="header-table">
#    <tr class="top-aligned-row">
#    <td><strong>Class</strong></td>
#    <td class="class-name-in-header">Rumld::Grapher</td>
#    </tr>
#    </table>
#    </div></body></html>'
#    @rdoc_inspector.expects(:doc).returns(Hpricot( string ))
#    assert ! @rdoc_inspector.doc_is_for_module?
#  end
#
#  def test_doc_should_open_the_doc_for_file_and_yield_to_hpricot
#    setup_rdoc
#    assert_kind_of Hpricot, @rdoc_inspector.doc
#  end
#
#  def test_doc_file_for_should_delegate_to_class_methods
#    Rumld::RDocInspector.expects(:doc_file_for).returns('hello')
#    assert_equal 'hello', @rdoc_inspector.doc_file_for
#  end
#
#  def test_methods_by_section_has_public_instance_methods
#    setup_rdoc
#    result = @rdoc_inspector.methods_by_section
#    assert result.has_key?(:public_instance)
#    assert result[:public_instance].include?('test_methods_by_section_has_public_instance_methods()')
#  end
#
#end
#