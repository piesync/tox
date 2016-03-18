require 'ox'
require 'pp'

require 'tox/version'
require 'tox/template'
require 'tox/parser'
require 'tox/renderer'

module Tox
  def self.dsl(&block)
    Template.dsl(&block)
  end
end
