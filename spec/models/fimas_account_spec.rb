# -*- encoding : utf-8 -*-

require 'spec_helper'

describe FimasAccount do
  describe 'responds to ' do
    characteristics = %i[description code]
    characteristics.each do |type|
      it { is_expected.to respond_to(type.to_sym) }
    end
  end
end
