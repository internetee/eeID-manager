module Actions
  class ContactCreate
    def initialize(user, main: false)
      @contact = Contact.new
      @contact.name = user.given_names
      @contact.email = user.email
      @contact.mobile_phone = user.mobile_phone
      @contact.identity_code = user.identity_code
      @contact.user_id = user.id
      @contact.main = main
    end

    def call
      @contact.save
    end
  end
end
