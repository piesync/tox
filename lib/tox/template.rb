module Tox
  class Template
    module DSL
      def self.el(name, sub)
        {
          cat: :elements,
          name: name,
          collect: false,
          sub: sub
        }
      end

      def self.mel(name, sub)
        el(name, sub).merge(collect: true)
      end

      def self.at(name)
        {
          cat: :attributes,
          name: name,
          collect: false,
          sub: {}
        }
      end

      def self.text
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
            t[:name] => invert(t[:sub]).merge(collect: t[:collect])
          }
        }
      else
        t.inject({}) do |h, (wrap, it)|
          h[it[:cat]] ||= {}
          h[it[:cat]].merge!({
            it[:name] => invert(it[:sub]).merge({
              merge: wrap, collect: it[:collect]
            })
          })
          h
        end
      end
    end
  end
end
