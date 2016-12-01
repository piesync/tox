module Tox
  class Renderer
    def initialize(t)
      @t = t
    end

    def render(o)
      rendered = [render_template(t, o)].flatten

      if rendered.first && rendered.first[:v]
        Ox::Document.new(version: '1.0', encoding: 'UTF-8') << rendered.first[:v]
      end
    end

    private

    def render_template(t, o)
      if t[:collect]
        o.map do |sub|
          render_template(t.merge(collect: false), sub)
        end
      elsif t[:cat] == :elements
        e = Ox::Element.new(t[:name]).tap do |el|
          [render_template(t[:sub], o)].flatten.each do |c|
            case c[:t]
            when :el   then el << c[:v]
            when :text then el.replace_text(c[:v]) if c[:v]
            when :at   then el[c[:n]] = c[:v]
            end
          end

          if t[:ns]
            t[:ns].each do |k, v|
              el[['xmlns', k].compact.join(':')] = v
            end
          end
        end

        { t: :el, v: e }
      elsif t[:cat] == :attributes
        { t: :at, v: o, n: t[:name] }
      elsif t[:cat] == :text
        { t: :text, v: o }
      else
        o.map do |key, sub|
          render_template(t[key], sub) if t[key]
        end.compact
      end
    end

    attr_reader :t
  end
end
