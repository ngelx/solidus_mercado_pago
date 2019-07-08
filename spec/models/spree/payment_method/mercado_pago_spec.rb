require 'spec_helper'

RSpec.describe Spree::PaymentMethod::MercadoPago do
  describe 'Methods' do
    subject(:payment_method) { described_class.new }

    it { expect(payment_method).to be_a(Spree::PaymentMethod) }
    it { expect(payment_method.payment_profiles_supported?).to eq false }
    it { expect(payment_method.provider_class).to eq MercadoPago::Client }
    it 'provider'
    it { expect(payment_method.source_required?).to eq false }
    it { expect(payment_method.auto_capture?).to eq false }

    describe 'sandbox' do
      let(:preferences) { { sandbox: true } }
      let(:payment_method) { described_class.new(preferences: preferences) }
      it 'stores sandbox value as model preference' do
        expect(payment_method.preferred_sandbox).to eq true
      end
    end

    it 'can_void?'

    it { expect(payment_method.actions).to eq %w[void] }

    it 'void call ActiveMerchant::Billing::Response.new' do
      expect(ActiveMerchant::Billing::Response).to receive(:new).with(true, '', {}, {})
      payment_method.void
    end
  end
end
