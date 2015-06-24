require 'rails_helper'

feature 'User signs in' do
  scenario 'with valid credentials' do
    visit sign_in_path
    fill_in 'Username', with: 'joe.example'
    fill_in 'Password', with: 'passw0rd' 
    click_on 'Sign In'

    expect(page).to have_content('You have successfully signed in!')
  end
end


feature 'Visitor signs up' do
  scenario 'with valid email and password' do
    sign_up_with 'valid@example.com', 'password'

    expect(page).to have_content('Sign out')
  end

  scenario 'with invalid email' do
    sign_up_with 'invalid_email', 'password'

    expect(page).to have_content('Sign in')
  end

  scenario 'with blank password' do
    sign_up_with 'valid@example.com', ''

    expect(page).to have_content('Sign in')
  end

  def sign_up_with(email, password)
    visit sign_up_path
    fill_in 'Email', with: email
    fill_in 'Password', with: password
    click_button 'Sign up'
  end
end