require 'spec_helper'

RSpec.describe Parliament::Utils::Helpers::PostcodeHelper, vcr: true do
  it 'is a module' do
    expect(Parliament::Utils::Helpers::PostcodeHelper).to be_a(Module)
  end

  pending do
    context 'given a valid postcode (no whitespace)' do
      it 'returns a Parliament::Response::NTripleResponse' do
        result = Parliament::Utils::Helpers::PostcodeHelper.lookup('E20JA')

        expect(result).to be_a(Parliament::Response::NTripleResponse)
        expect(result.nodes.first.constituencyGroupName).to eq('constituencyGroupName - 481')
      end
    end

    context 'given a valid postcode (containing whitespace)' do
      it 'returns a Parliament::Response::NTripleResponse' do
        result = Parliament::Utils::Helpers::PostcodeHelper.lookup(' E2  0JA ')

        expect(result).to be_a(Parliament::Response::NTripleResponse)
        expect(result.nodes.first.constituencyGroupName).to eq('constituencyGroupName - 481')
      end
    end

    context 'given an invalid postcode (containing non-postcode characters)' do
      it 'raises a PostcodeHelper::PostcodeError' do
        expect{ Parliament::Utils::Helpers::PostcodeHelper.lookup("<E2'0JA>") }.to raise_error(Parliament::Utils::Helpers::PostcodeHelper::PostcodeError, "We couldn't find the postcode you entered.")
      end
    end

    context 'given an invalid postcode (containing valid postcode characters)' do
      it 'raises a PostcodeHelper::PostcodeError' do
        expect{ Parliament::Utils::Helpers::PostcodeHelper.lookup('JE2 4NJ') }.to raise_error(Parliament::Utils::Helpers::PostcodeHelper::PostcodeError, "We couldn't find the postcode you entered.")
      end
    end

    context 'given the endpoint is down' do
      it 'raises a PostcodeHelper::PostcodeError' do
        stub_request(:get, "#{ENV['PARLIAMENT_BASE_URL']}/constituency_lookup_by_postcode?postcode=E20JA").
          to_return(status: [500, 'Internal Server Error'])

        expect{ Parliament::Utils::Helpers::PostcodeHelper.lookup('E2 0JA') }.to raise_error(Parliament::Utils::Helpers::PostcodeHelper::PostcodeError, 'Postcode check is currently unavailable.')
      end
    end

    context '#hyphenate' do
      it 'removes whitespace and adds a hyphen to a postcode' do
        expect(Parliament::Utils::Helpers::PostcodeHelper.hyphenate('E2 0SE')).to eq('E2-0SE')
      end
    end

    context '#unhyphenate' do
      it 'restores space and removes the hyphen from a postcode' do
        expect(Parliament::Utils::Helpers::PostcodeHelper.unhyphenate('E2-0SE')).to eq('E2 0SE')
      end
    end

    context '#previous_path' do
      it 'returns the previous path' do
        Parliament::Utils::Helpers::PostcodeHelper.previous_path = '/constituencies/current'

        expect(Parliament::Utils::Helpers::PostcodeHelper.previous_path).to eq('/constituencies/current')
      end
    end
  end
end
