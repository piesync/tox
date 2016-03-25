module Tox
  class Template
    module DSL
      extend self

      def el(name, sub, ns = {})
        {
          cat: :elements,
          name: name.to_sym,
          collect: false,
          sub: sub,
          ns: ns
        }
      end

      def mel(name, sub)
        el(name, sub).merge(collect: true)
      end

      def at(name)
        {
          cat: :attributes,
          name: name.to_sym,
          collect: false,
          sub: {}
        }
      end

      def text
        {
          cat: :text,
          name: :text,
          collect: false,
          sub: {}
        }
      end
    end

    def initialize(render_template)
      @render_template = render_template
      @parse_template  = invert(render_template)
    end

    def parse(xml, verbose = false)
      klass = verbose ? VerboseParser : Parser
      p = klass.new(@parse_template)
      Ox.sax_parse(p, xml)
      p.result
    end

    def render(o, verbose = false)
      r = Renderer.new(@render_template)
      Ox.dump(r.render(o))
    end

    def self.dsl(&block)
      Template.new(DSL.module_eval(&block))
    end

    private

    def invert(t)
      if t[:cat] && t[:cat].is_a?(Symbol)
        {
          t[:cat] => {
            t[:name] => invert(t[:sub]).merge(
              merge: t[:merge],
              collect: t[:collect]
            )
          }
        }
      else
        t.inject({}) do |h, (wrap, it)|
          h.merge!(invert(it.merge(merge: wrap))) do |k, o, n|
            o.merge(n)
          end
        end
      end
    end
  end
end
