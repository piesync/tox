require 'test_helper'
require 'benchmark'

class ToxTest < Minitest::Test
  def test_empty
    test_case(
      %{
        <name/>
      },
      nil
    ) do
      el(:name, text)
    end
  end

  def test_blank
    test_case(
      %{
        <name></name>
      },
      ''
    ) do
      el(:name, text)
    end
  end

  def test_simple_el
    test_case(
      %{
        <name>Mike</name>
      },
      "Mike"
    ) do
      el(:name, text)
    end
  end

  def test_simple_el_wrapped
    test_case(
      %{
        <name>Mike</name>
      },
      {
        firstname: "Mike"
      }
    ) do
      {
        firstname: el(:name, text)
      }
    end
  end

  def test_simple_el_double_wrapped
    test_case(
      %{
        <name>Mike</name>
      },
      {
        firstname: {
          value: "Mike"
        }
      }
    ) do
      {
        firstname: el(:name, {
          value: text
        })
      }
    end
  end

  def test_deep_text
    test_case(
      %{
        <t1><t2><t3>deep</t3></t2></t1>
      },
      "deep"
    ) do
      el(:t1, el(:t2, el(:t3, text)))
    end
  end

  def test_children
    test_case(
      %{
        <name>
          <first>Mike</first>
          <last>Ross</last>
        </name>
      },
      {
        f: 'Mike',
        l: 'Ross'
      }
    ) do
      el(:name, {
        f: el(:first, text),
        l: el(:last, text)
      })
    end
  end

  def test_collect
    test_case(
      %{
        <names>
          <name>Mike Ross</name>
          <name>Harvey Specter</name>
        </names>
      },
      ['Mike Ross', 'Harvey Specter']
    ) do
      el(:names, mel(:name, text))
    end
  end

  def test_collect_multi
    test_case(
      %{
        <col>
          <names>
            <name>Mike Ross</name>
            <name>Harvey Specter</name>
          </names>
          <ages>
            <age>25</age>
            <age>35</age>
          </ages>
        </col>
      },
      {
        names: ['Mike Ross', 'Harvey Specter'],
        ages: ['25', '35']
      }
    ) do
      el(:col, {
        names: el(:names, mel(:name, text)),
        ages: el(:ages, mel(:age, text))
      })
    end
  end

  def test_collect_mixed
    test_case(
      %{
        <col>
          <name>Mike Ross</name>
          <name>Harvey Specter</name>
          <age>25</age>
          <age>35</age>
        </col>
      },
      {
        names: ['Mike Ross', 'Harvey Specter'],
        ages: ['25', '35']
      }
    ) do
      el(:col, {
        names: mel(:name, text),
        ages: mel(:age, text)
      })
    end
  end

  def test_complex
    test_case(
      %{
        <profile>
          <first>Mike</first>
          <last>Ross</last>
          <friends>
            <friend>
              <first>Harvey</first>
              <last>Specter</last>
            </friend>
            <friend>
              <first>Louis</first>
              <last>Litt</last>
            </friend>
          </friends>
        </profile>
      },
      {
        f: 'Mike',
        l: 'Ross',
        friends: [
          {
            f: 'Harvey',
            l: 'Specter'
          },
          {
            f: 'Louis',
            l: 'Litt'
          }
        ]
      }
    ) do
      el(:profile, {
        f: el(:first, text),
        l: el(:last, text),
        friends: el(:friends, mel(:friend, {
          f: el(:first, text),
          l: el(:last, text)
        }))
      })
    end
  end

  def test_partial
    test_case_asym(
      %{
        <name>
          <first>Mike</first>
          <last>Ross</last>
        </name>
      },
      %{
        <name>
          <first>Mike</first>
        </name>
      },
      {
        f: 'Mike'
      }
    ) do
      el(:name, {
        f: el(:first, text)
      })
    end
  end

  def test_complex_scope
    test_case_asym(
      %{
        <profile>
          <first>Mike</first>
          <last>Ross</last>
          <friends>
            <friend>
              <first>Harvey</first>
              <last>Specter</last>
            </friend>
            <friend>
              <first>Louis</first>
              <last>Litt</last>
            </friend>
          </friends>
        </profile>
      },
      %{
        <profile>
          <first>Mike</first>
          <last>Ross</last>
          <friends>
            <friend>
              <first>Harvey</first>
            </friend>
            <friend>
              <first>Louis</first>
            </friend>
          </friends>
        </profile>
      },
      {
        f: 'Mike',
        l: 'Ross',
        friend_firstnames: ['Harvey', 'Louis']
      }
    ) do
      el(:profile, {
        f: el(:first, text),
        l: el(:last, text),
        friend_firstnames: el(:friends, mel(:friend, el(:first, text)))
      })
    end
  end

  def test_simple_attr
    test_case(
      %{
        <name age="25">Mike</name>
      },
      {
        name: 'Mike',
        age: '25'
      }
    ) do
      el(:name, {
        name: text,
        age: at(:age)
      })
    end
  end

  def test_single_attr
    test_case(
      %{
        <name age="25"/>
      },
      '25'
    ) do
      el(:name, at(:age))
    end
  end

  def test_performance
    if ENV['PERFORMANCE']
      template = Tox::Template.dsl do
        el(:profile, {
          f: el(:first, text),
          l: el(:last, text),
          friend_firstnames: el(:friends, mel(:friend, el(:first, text)))
        })
      end

      xml = %{
        <profile>
          <first>Mike</first>
          <last>Ross</last>
          <friends>
            <friend>
              <first>Harvey</first>
              <last>Specter</last>
            </friend>
            <friend>
              <first>Louis</first>
              <last>Litt</last>
            </friend>
          </friends>
        </profile>
      }

      value = {
        f: 'Mike',
        l: 'Ross',
        friend_firstnames: ['Harvey', 'Louis']
      }

      puts
      Benchmark.bm do |x|
        x.report do
          100_000.times do
            template.parse(xml)
          end
        end

        x.report do
          100_000.times do
            template.render(value)
          end
        end
      end
    end
  end

  private

  def test_case(xml, value, &template)
    test_case_asym(xml, xml, value, &template)
  end

  def test_case_asym(xml_parse, xml_render, value, &template)
    test_case_parse(xml_parse, value, &template)
    test_case_render(xml_render, value, &template)
  end

  def test_case_parse(xml, value, &template)
    template = Tox::Template.dsl(&template)
    assert_equal(value, template.parse(xml, false))
  end

  def test_case_render(xml, value, &template)
    template = Tox::Template.dsl(&template)
    assert_equal(
      scrub(xml),
      scrub(template.render(value))
    )
  end

  def scrub(str)
    str.gsub(/\n */, '')
  end
end
