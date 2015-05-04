class User < ActiveRecord::Base
  has_many :rounds
  has_many :decks
  has_many :cards, through: :deck
  has_many :guesses, through: :round

  #ZM: Remeber to remove junk comments
  # Remember to create a migration!
  def self.authenticate(name, password)
    if
      !User.find_by(name: name, password: password)
      "Thats not a valid name"
      return 'deny'
    end
  end

  #ZM: Where are the password methods? You are saving plaintext passwords into the database. this is danger
end
