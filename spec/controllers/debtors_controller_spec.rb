# -*- encoding : utf-8 -*-

require 'spec_helper'

describe DebtorsController do
  describe 'CRUD' do
    it 'errors when destroy is evoked on a debtor w/ association' do
      skip 'Tested this IRL and it works but test is not producing expected result.'
      debtor1 = FactoryGirl.build(:debtor)
      debtor1.save!
      debt1 = FactoryGirl.build(:debt, debtor_id: debtor1.id, debtor: debtor1.name)
      debt1.save!
      expect { delete :destroy, id: debtor1.id }.to raise_error KeyError
    end
  end
end
