require 'test_helper'

class TemplateElementTest < Minitest::Test
  def test_differ
    element_a = Tox::Template::Element.new(:name, :ns, { val: :a })
    element_b = Tox::Template::Element.new(:name, :ns, { val: :b })

    refute_equal element_a, element_b
  end
end
