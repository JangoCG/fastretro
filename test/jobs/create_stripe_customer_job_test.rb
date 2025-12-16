# frozen_string_literal: true

require "test_helper"

class CreateStripeCustomerJobTest < ActiveJob::TestCase
  setup do
    @identity = identities(:one)
    @identity.update!(stripe_customer_id: nil)
  end

  test "creates stripe customer and updates identity" do
    mock_customer = mock("customer")
    mock_customer.stubs(:id).returns("cus_new123")

    Stripe::Customer.expects(:create).with(
      email: @identity.email_address,
      metadata: { identity_id: @identity.id }
    ).returns(mock_customer)

    CreateStripeCustomerJob.perform_now(@identity)

    assert_equal "cus_new123", @identity.reload.stripe_customer_id
  end

  test "skips if identity already has stripe_customer_id" do
    @identity.update!(stripe_customer_id: "cus_existing")

    Stripe::Customer.expects(:create).never

    CreateStripeCustomerJob.perform_now(@identity)

    assert_equal "cus_existing", @identity.reload.stripe_customer_id
  end

  test "job is enqueued to default queue" do
    assert_equal "default", CreateStripeCustomerJob.new.queue_name
  end
end
