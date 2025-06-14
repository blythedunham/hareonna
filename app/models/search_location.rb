# Simple model to server side validation of search location input
class SearchLocation
  include ActiveModel::Model
  include ActiveModel::Validations
  include ActiveModel::Validations::Callbacks

  attr_accessor :location
  validates :location, presence: true, length: { minimum: 5 }

  before_validation :remove_whitespace

  private
  def remove_whitespace
    location.strip! if location.is_a?(String)
  end
end
