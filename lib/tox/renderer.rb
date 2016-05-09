module Tox
  class Renderer
    def initialize(t)
      @t = t
    end

    def render(o)
      Ox::Document.new(version: '1.0', encoding: 'UTF-8') << \
        [render_template(t, o)].flatten.first[:v]
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
            when :text then el.replace_text(stringify(c[:v])) unless c[:v].nil?
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

    def stringify(val)
      if [String, Numeric, TrueClass, FalseClass].any? { |klass| klass === val }
        val.to_s
      else
        raise ArgumentError, "Tox supports only string, numeric, boolean and nil types, but #{val.class} (#{val.inspect}) was given!"
      end
    end

    attr_reader :t
  end
end
