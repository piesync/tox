require 'pp'

module Tox
  class Parser
    def initialize(t)
      @s = [[t, nil]]
      @i = 0
    end

    def start_element(name)
      unless @i == 0 && push(descend(t, Template::Element, name, nil))
        @i+=1
      end
    end

    def end_element(name)
      if @i > 0
        @i-=1
      else
        fold
      end
    end

    def attr(name, value)
      fold if push(descend(t, Template::Attribute, name, value))
    end

    def text(str)
      fold if push(descend(t, Template::Text, nil, str.force_encoding('UTF-8')))
    end

    # At the end, we have the root element with an optional bunch of Transformations on top.
    # If the stack is still larger than the single root element, fold the remaining Transformations.
    def result
      @s.first[1] || t.default
    end

    private

    def t
      @s.last[0]
    end

    def v
      @s.last[1]
    end

    def descend(t, type, name, value)
      # First we need to determine which child to descend into. If the current template is a Transformation,
      # we need to look up the child to descend to using the index. If the current template is an XMLNode,
      # we only have a valid child if the child is a Transformation or if it is a matching XMLNode.
      child = if Template::Transformation === t
        t.index[type][name]
      else # Template::Element
        t.child if Template::Transformation === t.child || (type === t.child && name == t.child.name)
      end

      # If there is no child, there is no template for this node, so it is ignored. If the child is a
      # Transformation, we need to descend further.
      if child
        if Template::Transformation === child
          if d = descend(child, type, name, value)
            [[child, (v && t.value(child, v)) || child.default]].concat(d)
          end
        else
          [[child, value]]
        end
      end
    end

    def push(ss)
      @s.concat(ss) if ss
    end

    # When we fold, We don't want to fold Transformations prematurely. We only fold Transformations
    # when the parent XmlNode is closed. This means that we fold all Transformation on top of the stack
    # first and then do the fold for the closed XmlNode.
    def fold
      fold_single
      fold_single while Template::Transformation === t
    end

    def fold_single
      ti, vi, to, vo = *@s.pop, *@s.pop
      @s.push([to, to.fold(ti, vo, vi)])
    end
  end
end
