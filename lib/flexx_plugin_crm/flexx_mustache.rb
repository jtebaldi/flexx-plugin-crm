require 'mustache'

module FlexxPluginCrm
  class FlexxMustache < Mustache
    def escape(txt)
      return txt
    end
  end
end
