module Mongoid
    module MyDbTools
      extend ActiveSupport::Concern
      include Mongoid::Document
      include Mongoid::Attributes::Dynamic

    end
end