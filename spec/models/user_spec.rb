# -*- encoding : utf-8 -*-

require 'spec_helper'

describe User do
  let(:happy_user) do
    FactoryGirl.create(:user)
  end

  # before do #for Controller tests
  #   sign_in :happy_user
  # end

  describe 'responds to ' do
    characteristics = %i[email encrypted_password reset_password_token
                         current_sign_in_ip]
    characteristics.each do |type|
      it { is_expected.to respond_to(type.to_sym) }
    end
  end

  describe 'Invalidations' do
    describe 'when password is not present' do
      it 'user without password should not be valid' do
        expect { happy_user.password = '' }.to raise_error ActiveRecord::RecordInvalid
      end
    end
  end
end

#     t.string   "email",                  default: "", null: false
#     t.string   "encrypted_password",     default: "", null: false
#     t.string   "reset_password_token"
#     t.datetime "reset_password_sent_at"
#     t.datetime "remember_created_at"
#     t.integer  "sign_in_count",          default: 0,  null: false
#     t.datetime "current_sign_in_at"
#     t.datetime "last_sign_in_at"
#     t.string   "current_sign_in_ip"
#     t.string   "last_sign_in_ip"
#     t.datetime "created_at"
#     t.datetime "updated_at"
