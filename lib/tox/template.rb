module Tox
  class Template
    module DSL
      extend self

      def template(d)
        Template.new(d)
      end

      def el(name, child, ns = {})
        Element.new(name.to_sym, ns, compose(child))
      end

      def mel(name, child)
        Collect.new(el(name, child))
      end

      def collect(child)
        Collect.new(compose(child))
      end

      def at(name)
        Attribute.new(name.to_sym)
      end

      def text
        Text.new
      end

      def compose(o)
        if Hash === o
          Compose.new(o)
        else
          o
        end
      end

      def compose_all(els)
        els.map do |el|
          compose(el)
        end
      end

      def merge(*children)
        Merge.new(compose_all(children))
      end

      def const(value, child)
        Const.new(value, child)
      end
    end

    def initialize(template)
      @template = Element.new(nil, nil, DSL.compose(template))
    end

    def parse(xml)
      p = Parser.new(@template)
      Ox.sax_parse(p, xml, skip: :skip_none)
      p.result
    end

    def render(o, pretty: false)
      r = Renderer.new(@template).render(o)

      options = {}
      options[:indent] = -1 if !pretty

      r ? Ox.dump(r, options) : ''
    end

    def self.dsl(&block)
      Template.new(DSL.module_eval(&block))
    end

    private

    # These are for matching actual XML Nodes ----------

    class XMLNode < Struct.new(:name, :ns)
      def default
        nil
      end

      def nodes
        [self]
      end
    end

    class Element < XMLNode
      attr_reader :child

      def initialize(name, ns, child)
        super(name, ns)
        @child = child
      end

      def default
        child.default
      end

      def value(child, v)
        v
      end

      def fold(_, _, v)
        v
      end
    end

    class Attribute < XMLNode
    end

    class Text < XMLNode
    end

    # These are for transforming the structure ---------

    class Transformation
      attr_reader :children

      def initialize(children)
        @children = children
      end

      def index
        @index ||= {
          Element => {},
          Attribute => {},
          Text => {}
        }.tap do |index|
          children.each do |t|
            t.nodes.each do |ct|
              index[ct.class][ct.name] = t
            end
          end
        end
      end

      def nodes
        children.flat_map(&:nodes)
      end

      def value(child, v)
        nil
      end
    end

    # Composes subtemplates in a hash.
    class Compose < Transformation
      def initialize(dict)
        super(dict.values)
        @dict = dict
        @idict = dict.invert
      end

      def default
        {}
      end

      def value(child, v)
        v[@idict[child]]
      end

      def walk(v)
        v && v.each do |k, v|
          yield(@dict[k], v) if @dict[k]
        end
      end

      def fold(t, vo, vi)
        vo[@idict[t]] = vi
        vo
      end
    end

    # Collects multiple occurences of given template in a list.
    class Collect < Transformation
      def initialize(child)
        @child = child
        super([child])
      end

      def default
        []
      end

      def walk(v)
        v && v.each do |vv|
          yield(@child, vv)
        end
      end

      def fold(t, vo, vi)
        vo << vi
        vo
      end
    end

    # Merges hash results of multiple templates.
    class Merge < Transformation
      def default
        {}
      end

      def value(child, v)
        v
      end

      def walk(v)
        children.each do |t|
          yield(t, v)
        end
      end

      def fold(t, vo, vi)
        vo.merge!(vi) if Hash === vi
        vo
      end
    end

    class Const < Transformation
      def initialize(value, child)
        @value = value
        @child = child
        super([child])
      end

      def default
        nil
      end

      def value(child, v)
        @value
      end

      def walk(v)
        yield(@child, @value)
      end

      def fold(*)
        nil
      end
    end
  end
end
