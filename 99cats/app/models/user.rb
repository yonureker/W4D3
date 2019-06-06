# == Schema Information
#
# Table name: users
#
#  id              :bigint           not null, primary key
#  user_name       :string           not null
#  password_digest :string           not null
#  session_token   :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class User < ApplicationRecord
  validates :user_name, :password_digest, :session_token, presence: true
  validates :user_name, :session_token, uniqueness: true
  after_initialize :ensure_session_token

  attr_reader :password

  has_many :cats,
    foreign_key: :user_id,
    class_name: 'Cat'

  has_many :rental_requests,
    foreign_key: :user_id,
    class_name: :CatRentalRequest


  def self.find_by_credentials(user_name, password)
    user = User.find_by(user_name: user_name)

    return nil unless user
    user.is_password?(password) ? user : nil
  end

  def reset_session_token!
    self.session_token = SecureRandom.urlsafe_base64 #generates a random session_token
    self.save! #to save the session token to our user object and get a loud error
    self.session_token #return to methods that call it like login!  
  end

  def password=(password)
    @password = password
    self.password_digest = BCrypt::Password.create(password)
  end

  def is_password?(password)
    BCrypt::Password.new(self.password_digest).is_password?(password)
  end

  def ensure_session_token
    self.session_token ||= SecureRandom.urlsafe_base64
  end
end
