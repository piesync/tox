module Tox
  class Renderer
    def initialize(t)
      @t = t
    end

    def render(o)
      rendered = render_template(@t.child, o).map(&:last)

      if rendered
        Ox::Document.new(version: '1.0', encoding: 'UTF-8').tap do |doc|
          rendered.each do |node|
            doc << node
          end
        end
      end
    end

    private

    def render_template(t, v)
      case t
      when Template::Transformation
        nodes = []
        t.walk(v) do |tt, vv|
          nodes.concat(render_template(tt, vv))
        end

        nodes

      when Template::Element
        e = Ox::Element.new(t.name)

        render_template(t.child, v).each do |type, value, name = nil|
          case type
          when :e
            e << value
          when :a
            e[name] = value
          when :t
            e.replace_text(stringify(value)) unless value.nil?
          end
        end

        if t.ns
          t.ns.each do |k, v|
            e[['xmlns', k].compact.join(':')] = v
          end
        end

        [[:e, e]]

      when Template::Attribute
        [v && [:a, v, t.name]]

      when Template::Text
        [[:t, v]]
      else
        t
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
