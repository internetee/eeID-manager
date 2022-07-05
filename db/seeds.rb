# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# Administrator (initial user)
administrator = User.new(given_names: 'Default', surname: 'Administrator',
                         email: 'admin@eid.test', password: 'adminadmin',
                         password_confirmation: 'adminadmin', country_code: 'EE',
                         mobile_phone: '+37250060070', identity_code: '51007050118',
                         billing_recipient: 'Admin', billing_street: 'Street',
                         billing_city: 'Tallinn', billing_zip: '12345',
                         billing_alpha_two_country_code: 'EE',
                         roles: [User::ADMINISTRATOR_ROLE], accepts_terms_and_conditions: true)
administrator.skip_confirmation!
administrator.save!
