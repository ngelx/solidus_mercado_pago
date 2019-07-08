require 'spec_helper'
require 'json'

RSpec.describe MercadoPago::Client, type: :model do
  SPEC_ROOT = File.expand_path('../', File.dirname(__FILE__))

  let(:payment_method) { double('payment_method', preferred_client_id: 1, preferred_client_secret: 1) }

  let(:order) { double('order', payment_method: payment_method, number: 'testorder', line_items: [], ship_total: 1000) }
  let(:url_callbacks) { { success: 'url', failure: 'url', pending: 'url' } }
  let(:payment_method) { double :payment_method, id: 1, preferred_client_id: 'app id', preferred_client_secret: 'app secret' }
  let(:payment) { double :payment, payment_method: payment_method, id: 1, identifier: 'fruta' }

  let(:login_json_response) { File.open("#{SPEC_ROOT}/../fixtures/authenticated.json").read }
  let(:preferences_json_response) { File.open("#{SPEC_ROOT}/../fixtures/preferences_created.json").read }
  let(:client) { MercadoPago::Client.new(payment_method) }

  describe '#initialize' do
    it "doesn't raise error with all params" do
      expect { client }.not_to raise_error
    end
  end

  describe '#authenticate' do
    context 'On success' do
      let(:http_response) do
        response = double('response')
        allow(response).to receive(:code).and_return 200
        allow(response).to receive(:to_str).and_return login_json_response
        response
      end
      let(:js_response) { JSON.parse(http_response) }

      before do
        allow(RestClient).to receive(:post).and_return(http_response)
      end

      it 'returns a response object' do
        expect(client.authenticate).to eq(js_response)
      end

      it '#errors returns empty array' do
        client.authenticate
        expect(client.errors).to be_empty
      end

      it 'sets the access token' do
        client.authenticate
        expect(client.auth_response['access_token']).to eq('TU_ACCESS_TOKEN')
      end
    end

    context 'On failure' do
      let(:bad_request_response) do
        response = double('response')
        allow(response).to receive(:code).and_return 400
        allow(response).to receive(:to_str).and_return ''
        response
      end

      before do
        allow(RestClient).to receive(:post).and_raise(RestClient::Exception.new('foo'))
      end

      it 'raise exception on invalid authentication' do
        expect { client.authenticate }.to raise_error(RuntimeError) do |_error|
          expect(client.errors).to include(I18n.t(:authentication_error, scope: :mercado_pago))
        end
      end
    end
  end

  describe '#check_payment_status' do
    let(:collection) { {} }
    let(:expected_response) { { results: [collection: collection] } }

    before do
      allow(subject).to receive(:send_search_request).with(external_reference: payment.id).and_return(expected_response)
      allow(subject).to receive(:check_status).with(payment, {})
    end
  end

  describe '#create_preferences' do
    context 'On success' do
      subject(:create_preference) { client.create_preferences(preferences) }

      let(:preferences) { { foo: 'bar' } }

      before do
        response = double('response')
        allow(response).to receive(:code).and_return(200, 201)
        allow(response).to receive(:to_str).and_return(login_json_response, preferences_json_response)
        allow(RestClient).to receive(:post).exactly(2).times { response }
        client.authenticate
      end

      it 'return value should not be nil' do
        expect(create_preference).to be_truthy
      end

      describe '#redirect_url returns offsite checkout url' do
        it 'sandobox false' do
          allow(client).to receive(:sandbox).and_return(false)
          create_preference
          expect(client.redirect_url).to eq('https://www.mercadopago.com/checkout/pay?pref_id=identificador_de_la_preferencia')
        end
        it 'sandobox true' do
          allow(client).to receive(:sandbox).and_return(true)
          create_preference
          expect(client.redirect_url).to eq('https://www.mercadopago.com/checkout/sandbox')
        end
      end
    end

    context 'on failure' do
      before do
        expect(RestClient).to receive(:post).exactly(2).times do
          if !@is_second_time
            @is_second_time = true
            '{}'
          else
            raise RestClient::Exception, 'foo'
          end
        end
        client.authenticate
      end

      let(:preferences) { { foo: 'bar' } }

      it 'throws exception and populate errors' do
        expect { client.create_preferences(preferences) }.to raise_error(RuntimeError) do |_variable|
          expect(client.errors).to include(I18n.t(:authentication_error, scope: :mercado_pago))
        end
      end
    end
  end

  context 'payment method with preferences' do
    let(:preferences) do
      {
        client_id: '6nVDZ8MsMS',
        client_secret: 'o5ODEtNt6h',
        sandbox: false
      }
    end

    let(:payment_method) { Spree::PaymentMethod::MercadoPago.new(preferences: preferences) }

    let(:mercado_pago) { described_class.new(payment_method) }

    describe '#client_id' do
      it 'comes from payment method' do
        expect(mercado_pago.send(:client_id)).to eq payment_method.preferred_client_id
      end
    end

    describe '#client_secret' do
      it 'comes from payment method' do
        expect(mercado_pago.send(:client_secret)).to eq payment_method.preferred_client_secret
      end
    end

    describe '#sandbox' do
      it 'comes from payment method' do
        expect(mercado_pago.send(:sandbox)).to eq payment_method.preferred_sandbox
      end
    end
  end
end
