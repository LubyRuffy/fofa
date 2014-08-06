require 'test_helper'

class SearchHelperTest < ActionView::TestCase
  def test_app_processor
    query = 'title="test title"'
    http = {"title"=>'abc test title 123'}
    assert(AppProcessor.parse(query, http))
  end
end
