class ContactsController < ApplicationController
  before_action :authenticate_user!, only: %i[show edit update destroy edit_authwall]
  before_action :set_contact, only: %i[show edit update destroy]

  def index
    @contacts = current_user.contacts.page(params[:page])
  end

  def show; end

  def new
    @contact = current_user.contacts.new
  end

  def edit; end

  def create
    @contact = current_user.contacts.new(contacts_params)
    unmark_old_default if @contact.valid? && @contact.default

    respond_to do |format|
      if @contact.save
        format.html { redirect_to @contact, notice: 'Contact was successfully created.' }
        format.json { render :show, status: :created, location: @contact }
      else
        format.html { render :new }
        format.json { render json: @contact.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @contact.update(contacts_params)
        format.html { redirect_to @contact, notice: 'Contact was successfully updated.' }
        format.json { render :show, status: :ok, location: @contact }
      else
        format.html { render :edit }
        format.json { render json: @contact.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    respond_to do |format|
      if @contact.destroy_enabled? && @contact.destroy
        format.html { redirect_to contacts_url, notice: 'Contact was successfully destroyed.' }
        format.json { head :no_content }
      else
        format.html do
          redirect_to contacts_url,
                      notice: "The contact #{@contact.name} is used by the next services: #{@contact.service_list}"
        end
        format.html { render :show }
      end
    end
  end

  def contacts_params
    params.require(:contact).permit(:name, :email, :mobile_phone, :identity_code, :default)
  end

  private

  def unmark_old_default
    contacts = current_user.contacts.default
    contacts.update_all(default: false)
  end

  def set_contact
    @contact = current_user.contacts.find(params[:id])
  end
end
