require 'minitest/autorun'
require 'synchrocat'

class SynchrocatTest < Minitest::Test
  def test_destination_path_when_nil
    expected = 'README.md'
    actual = Synchrocat.destination_path(nil, 'README.md')
    assert_equal expected, actual
  end

  def test_destination_path_when_empty
    expected = 'README.md'
    actual = Synchrocat.destination_path('', 'README.md')
    assert_equal expected, actual
  end

  def test_destination_path_when_leading_slash
    expected = 'README.md'
    actual = Synchrocat.destination_path('/', 'README.md')
    assert_equal expected, actual
  end

  def test_destination_path_when_dir
    expected = 'docs/README.md'
    actual = Synchrocat.destination_path('docs', 'README.md')
    assert_equal expected, actual
  end

  def test_destination_path_when_nested_dir
    expected = 'project/docs/README.md'
    actual = Synchrocat.destination_path('project/docs', 'README.md')
    assert_equal expected, actual
  end

  def test_destination_path_when_dir_with_trailing_slash
    expected = 'docs/README.md'
    actual = Synchrocat.destination_path('docs/', 'README.md')
    assert_equal expected, actual
  end

  def test_destination_path_when_dot
    skip 'Not yet supported'
    expected = 'README.md'
    actual = Synchrocat.destination_path('.', 'README.md')
    assert_equal expected, actual
  end
end
