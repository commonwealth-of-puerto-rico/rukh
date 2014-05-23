require 'spec_helper'

describe User do
  let(:happy_user) { FactoryGirl.create(:user)
  }
  # before do #for Controller tests
  #   sign_in :happy_user
  # end
  
  describe "responds to " do
    characteristics = [:email, :encrypted_password, :reset_password_token,
      :current_sign_in_ip
    ]
    characteristics.each do |type|
      it {should respond_to(type.to_sym)}
    end
  end
  
  
end

=begin
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
=end