module Spree
  class PaymentMethod::MercadoPago < PaymentMethod

    preference :sandbox, :boolean, default: true
    preference :client_id, :string, default: nil
    preference :client_secret, :string, default: nil

    def payment_profiles_supported?
      false
    end

    def provider_class
      ::MercadoPago::Client
    end

    def provider(additional_options = {})
      @provider ||= begin
                      options = { sandbox: preferred_sandbox }
                      client = provider_class.new(self, options.merge(additional_options))
                      client.authenticate
                      client
                    end
    end

    def source_required?
      false
    end

    def auto_capture?
      false
    end

    ## Admin options

    def can_void?(payment)
      payment.state != 'void'
    end

    def actions
      %w[void]
    end

    def void(*_args)
      ActiveMerchant::Billing::Response.new(true, '', {}, {})
    end
  end
end
