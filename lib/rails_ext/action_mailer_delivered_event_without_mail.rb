# Rails 8.1 has no prepended notification subscribers. Filter the encoded copy
# when its payload is built, leaving the message used for delivery untouched.
module ActionMailerDeliveredEventWithoutMail
  private
    def set_payload_for_mail(payload, mail)
      super
      payload[:mail] = "[FILTERED]"
    end
end

ActiveSupport.on_load(:action_mailer) do
  singleton_class.prepend ActionMailerDeliveredEventWithoutMail
end
