require 'digest/sha1'

class Member < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken
  
  acts_as_network :friends, :through => :invites, :conditions => ["is_accepted = ?", true] 
  acts_as_messageable
  
  has_many :invites
  has_many :line_curriculum
  has_many :promotions, :through => :line_curriculum, :source => :member
  has_many :firms, :through => :line_curriculum, :source => :member
  has_many :schools, :through => :line_curriculum, :source => :member
  
  
  
  validates_presence_of     :login
  validates_length_of       :login,    :within => 3..40
  validates_uniqueness_of   :login
  validates_format_of       :login,    :with => Authentication.login_regex, :message => Authentication.bad_login_message

  validates_presence_of     :civil_state

  validates_presence_of     :first_name
  validates_format_of       :first_name,     :with => Authentication.name_regex,  :message => Authentication.bad_login_message
  validates_length_of       :first_name,     :maximum => 100
  validates_presence_of     :last_name
  validates_format_of       :last_name,     :with => Authentication.name_regex,  :message => Authentication.bad_name_message
  validates_length_of       :last_name,     :maximum => 100

  validates_length_of       :email,    :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email
  validates_format_of       :email,    :with => Authentication.email_regex, :message => Authentication.bad_email_message

  

  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :first_name, :activation_code, :civil_state, :last_name, :town, :region, :zipcode, :password, :password_confirmation

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  # uff.  this is really an authorization, not authentication routine.  
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  #
  
  def admin?
    login == "admin"
  end
  
  def self.authenticate(login, password)
    return nil if login.blank? || password.blank?
    u = find_by_login(login.downcase) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  def login=(value)
    write_attribute :login, (value ? value.downcase : nil)
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end

  protected
    


end
