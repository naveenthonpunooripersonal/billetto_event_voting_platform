module AuthenticationHelpers
  def sign_in_as(user_id = "clerk_test_user_123")
    @test_user_id = user_id
  end

  def sign_out
    @test_user_id = nil
  end
end