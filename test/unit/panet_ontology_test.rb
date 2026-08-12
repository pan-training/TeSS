require 'test_helper'

class PanetOntologyTest < ActiveSupport::TestCase
  test 'should lookup term' do
    term = Panet::Ontology.instance.lookup('http://purl.org/pan-science/PaNET/PaNET2020044')

    assert term
    assert_equal 'emission momentum', term.preferred_label
    assert_empty term.synonyms
  end

  test 'should lookup term by name' do
    term = Panet::Ontology.instance.lookup_by_name('x-ray absorption spectroscopy')

    assert term
    assert_equal 'x-ray absorption spectroscopy', term.preferred_label
  end

  test 'should find topics by subset' do
    terms = Panet::Ontology.instance.all_topics

    assert terms.any?
    assert_includes terms.map(&:preferred_label), 'emission momentum'
    assert_includes terms.map(&:preferred_label), 'neutron time of flight technique'
  end

  test 'should scoped lookup by name' do
    term = Panet::Ontology.instance.scoped_lookup_by_name('electron emission', EDAM.topics)

    assert term
    assert_equal 'electron emission', term.preferred_label
  end
end