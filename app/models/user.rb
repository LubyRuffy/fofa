class User < ActiveRecord::Base
  self.table_name="user"

  has_merit

  has_many :rules
  has_many :categories
  has_many :userhosts
  has_many :usertargets
  has_many :targets, through: :usertargets
  has_many :sensitives

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  validates :username,
            :uniqueness => {
                :case_sensitive => false
            }

  attr_accessor :login
  attr_accessor :avatar
  has_attached_file :avatar,
      styles: { medium: "50x50>", thumb: "30x30>" },
      default_url: "/missing.jpg"
  validates_attachment_content_type :avatar,
                                    content_type: /\Aimage\/.*\Z/

  def login=(login)
    @login = login
  end

  def login
    name = @login
    name ||= self.username
    name = self.email if !name || name.size<1
    name
  end


  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    else
      where(conditions).first
    end
  end
end
