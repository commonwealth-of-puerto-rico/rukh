# -*- encoding : utf-8 -*-
require 'spec_helper'

describe FimasAccount do
  describe "responds to " do
    characteristics = [:description, :code]
    characteristics.each do |type|
      it {should respond_to(type.to_sym)}
    end
  end
end
