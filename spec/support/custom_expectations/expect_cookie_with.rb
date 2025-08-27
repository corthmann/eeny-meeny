# frozen_string_literal: true

def expect_set_cookie_with(response: {}, value: '')
  expect(response).to be
  expect(response[Rack::SET_COOKIE]).to be_an(Array)
  expect(response[Rack::SET_COOKIE]).to_not be_empty
  expect(response[Rack::SET_COOKIE].find { |cookie_string| cookie_string.include?(value) }).to be
end
