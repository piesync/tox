module Tox
  class Parser
    def initialize(t)
      @t = [t]
      @s = []
      @i = 0 # Number of levels ignoring
    end

    def start_element(name)
      push_child(@t.last, :elements, name, nil)
    end

    def end_element(name)
      fold
    end

    def attr(name, str)
      push_child(@t.last, :attributes, name, str)
      fold
    end

    def text(str)
      push_child(@t.last, :text, :text, str.force_encoding('UTF-8'))
      fold
    end

    def result
      @s.first
    end

    protected

    def push(t, v)
      @t << t
      @s << v
    end

    def push_child(t, cat, name, v)
      if n = (t && t[cat] && t[cat][name])
        push(n, v)
      else
        @i += 1
      end
    end

    def fold
      if @i > 0
        @i -= 1
      else
        t = @t.pop
        vi, vo = @s.pop, @s.pop

        @s.push(merge(t, vi, vo))
      end
    end

    def merge(t, vi, vo)
      merge   = t[:merge]
      collect = t[:collect]

      if collect && merge
        vo ||= {}
        if vo[merge]
          vo[merge] = vo[merge].concat([vi])
        else
          vo[merge] = [vi]
        end
        vo
      elsif collect
        vo ||= []
        vo << vi
      elsif merge
        vo ||= {}
        vo[merge] = vi
        vo
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
