class ChangePlanService
  def call(subscription_record, new_plan_id)
    subscription_record.update!(plan_id: new_plan_id)

    return if subscription_record.customer_id.blank?

    customer = Stripe::Customer.retrieve(subscription_record.customer_id)

    if subscription_record.subscription_id.blank?
      subscription = customer.subscriptions.create(plan: subscription_record.plan.stripe_id)
      subscription_record.update!(subscription_id: subscription.id, active_until: arbitrary_future_date)
    else
      subscription = customer.subscriptions.retrieve(subscription_record.subscription_id)
      subscription.plan = subscription_record.plan.stripe_id
      subscription.save
    end
  end

  private

  def arbitrary_future_date
    30.days.from_now
  end
end
