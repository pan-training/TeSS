require 'test_helper'

class SearchHelperTest < ActionView::TestCase
  test 'filter_form submits scientific topics as a get form while preserving existing filters' do
    @model = Material

    singleton_class.define_method(:params) do
      ActionController::Parameters.new(
        q: 'proteomics',
        scientific_topics: ['Genomics'],
        include_archived: 'true',
        page: '3'
      )
    end

    html = filter_form('scientific_topics', 'Metabolomics', 7, class: 'facet-option')

    assert_includes html, 'method="get"'
    assert_includes html, 'action="/materials"'
    assert_includes html, 'class="facet-option facet-option-button"'
    assert_includes html, 'name="q"'
    assert_includes html, 'value="proteomics"'
    assert_includes html, 'name="include_archived"'
    assert_includes html, 'value="true"'
    assert_match(/name="scientific_topics\[\]"[^>]*value="Genomics"/, html)
    assert_match(/name="scientific_topics\[\]"[^>]*value="Metabolomics"/, html)
    refute_includes html, 'name="page"'
  end
end
