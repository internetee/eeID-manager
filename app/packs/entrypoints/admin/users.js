// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

let checkbox = document.querySelector('#user_accepts_terms_and_conditions');
let updateButton = document.querySelector('#user_form_commit');

checkbox.addEventListener('change', (e) => {
    if (e.target.checked) {
        updateButton.disabled = false;
    } else {
        updateButton.disabled = true;
    }
});

let user_roles_administrator = document.querySelector('#user_roles_administrator');
let user_roles_customer = document.querySelector('#user_roles_customer');

user_roles_administrator.addEventListener('change', (e) => {
    if (e.target.checked) {
        user_roles_customer.checked = false;
    } else {
        user_roles_customer.checked = true;
    }
});

user_roles_customer.addEventListener('change', (e) => {
    if (e.target.checked) {
        user_roles_administrator.checked = false;
    } else {
        user_roles_administrator.checked = true;
    }
});
