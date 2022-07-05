module ApplicationHelper
  def navigation_links(current_user)
    content_tag(:ul) do
      if current_user&.admin?
        links(administrator_link_list)
      elsif current_user&.role?(User::CUSTOMER_ROLE)
        links(user_link_list)
      end
    end
  end

  def status_pill(status)
    colors = {
      ACTIVE: 'green',
      AWAITING_APPROVAL: 'purple',
      REJECTED: 'black',
      SUSPENDED: 'orange',
      ARCHIVED: 'black',
    }.with_indifferent_access

    "<a class='ui #{colors[status]} label'>#{status}</a>".html_safe
  end

  private

  def links(links_list)
    links_list.each do |item|
      concat(
        content_tag(:li) do
          link_to(item[:name], item[:path], method: item[:method], class: 'item', data: item[:data])
        end
      )
    end
  end

  def user_link_list
    [{ name: 'Dashboard', path: dashboard_path },
     { name: 'Services', path: services_path },
     { name: 'Contacts', path: contacts_path },
     { name: 'Authentications', path: authentications_path },
     { name: 'Billing', path: invoices_path },
     { name: 'Account', path: me_path }]
  end

  def administrator_link_list
    [{ name: 'Services', path: admin_services_path },
      { name: 'Authentications', path: admin_authentications_path },
      { name: 'Billing', path: admin_invoices_path },
      { name: 'Users', path: admin_users_path }]
  end
end
