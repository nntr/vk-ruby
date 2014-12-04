require 'helpers'

describe VK::Auth, type: :application do
  let(:options) {{
    app_id: :test_id,
    app_secret: :test_secret,
    access_token: :test_token,
    redirect_uri: '--'
  }}

  before { stubs_auth! }

  context 'serverside' do
    let(:code)   { 'test_code' }
    let(:result) {
      {
        "client_id"=>"test_id",
        "client_secret"=>"test_secret",
        "code"=> code,
        "redirect_uri" => '--',
        "v" => "5.26"
      }
    }

    it { expect{ subject.site_auth(code: code) }.to_not raise_error }
    it { subject.site_auth(code: code).should eq(result) }
  end

  context 'secure' do
    let(:result) {{
      "client_id"=>"test_id",
      "client_secret"=>"test_secret",
      "grant_type"=>"client_credentials"
    }}

    it { expect{ subject.server_auth }.to_not raise_error }
    it { subject.server_auth.should eq(result) }
  end

end