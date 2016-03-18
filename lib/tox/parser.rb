module Tox
  class Parser
    def initialize(t)
      @t = [t]
      @s = []
    end

    def start_element(name)
      push_child(t, :elements, name, nil)
    end

    def end_element(name)
      fold
    end

    def attr(name, str)
      push_child(t, :attributes, name, str)
      fold
    end

    def text(str)
      push_child(t, :text, :text, str.force_encoding('UTF-8'))
      fold
    end

    def result
      @s.first
    end

    protected

    def t
      @t.last
    end

    def push(t, v)
      @t.push(t)
      @s.push(v)
    end

    def push_child(t, cat, name, v)
      if t && t[cat] && t[cat][name]
        push(t[cat][name], v)
      else
        push(nil, nil)
      end
    end

    def fold
      t = @t.pop
      vi, vo = @s.pop, @s.pop

      @s.push(merge(t, vi, vo))
    end

    def merge(t, vi, vo)
      return vo if t.nil?

      if t[:collect] && t[:merge]
        vo ||= {}
        vo.merge!({ t[:merge] => [vi] }) do |k, o, n|
          o + n
        end
      elsif t[:collect]
        vo ||= []
        vo << vi
      elsif t[:merge]
        vo ||= {}
        vo.merge!({ t[:merge] => vi })
      else # pass up
        vi
      end
    end
  end

  class VerboseParser < Parser
    def start_element(name)
      puts "start #{name}"
      super
    end

    def end_element(name)
      puts "end #{name}"
      super
    end

    def attr(name, str)
      puts "attr #{name}"
      super
    end

    def text(str)
      puts "text"
      super
    end

    protected

    def push(*)
      super
      print_state('pushing')
    end

    def fold(*)
      super
      print_state('folding')
    end

    def print_state(a)
      puts "\n#{a}"
      pp @t
      pp @s
      puts
    end
  end
end
