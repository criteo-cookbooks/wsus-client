require 'spec_helper'
require_relative '../../libraries/helper'

describe WsusClient::Helper, unit: true do
  describe :get_install_day do
    INSTALL_DAYS = {
      every_day: 0, sunday: 1, monday: 2, tuesday: 3,
      wednesday: 4, thursday: 5, friday: 6, saturday: 7
    }.freeze

    it 'works with valid string' do
      INSTALL_DAYS.each do |day, value|
        expect(WsusClient::Helper.get_install_day(day.to_s)).to eq(value)
      end
    end

    it 'works with valid symbol' do
      INSTALL_DAYS.each do |day, value|
        expect(WsusClient::Helper.get_install_day(day.to_sym)).to eq(value)
      end
    end

    it 'fails on invalid value' do
      ['invalid_string', :invalid_symbol, 42, {}].each do |value|
        msg = "Invalid 'schedule_install_day' value of '#{value}'"
        expect { WsusClient::Helper.get_install_day value }.to raise_error(RuntimeError, msg)
      end
    end
  end

  describe :get_behavior do
    BEHAVIORS = { disabled: 1, detect: 2, download: 3, install: 4, manual: 5 }.freeze

    it 'works with valid string' do
      BEHAVIORS.each do |behavior, value|
        expect(WsusClient::Helper.get_behavior(behavior.to_s)).to eq(value)
      end
    end

    it 'works with valid symbol' do
      BEHAVIORS.each do |behavior, value|
        expect(WsusClient::Helper.get_behavior(behavior.to_sym)).to eq(value)
      end
    end

    it 'fails on invalid value' do
      ['invalid_string', :invalid_symbol, 42, {}].each do |value|
        msg = "Invalid 'automatic_update_behavior' value of '#{value}'"
        expect { WsusClient::Helper.get_behavior value }.to raise_error(RuntimeError, msg)
      end
    end
  end

  describe :check_limit do
    CONF_HASH = { key1: 12, key2: 42, zero: 0, negative: -1 }.freeze

    it 'succeeds with valid existing key and value is between 0 and the limit (included)' do
      expect { WsusClient::Helper.check_limit(CONF_HASH, :key1, 20) }.to_not raise_error
      expect { WsusClient::Helper.check_limit(CONF_HASH, :key2, 42) }.to_not raise_error
      expect { WsusClient::Helper.check_limit(CONF_HASH, :zero, 10) }.to_not raise_error
    end

    it 'fails with non existing key' do
      expect { WsusClient::Helper.check_limit(CONF_HASH, :non_existing, 20) }.to raise_error
    end

    it 'fails with invalid hash' do
      expect { WsusClient::Helper.check_limit(nil, :key1, 20) }.to raise_error
    end

    it 'fails when value is less than 0' do
      expect { WsusClient::Helper.check_limit(CONF_HASH, :negative, 20) }.to raise_error
    end

    it 'fails when value is greater than the specified limits' do
      expect { WsusClient::Helper.check_limit(CONF_HASH, :key1, 10) }.to raise_error
      expect { WsusClient::Helper.check_limit(CONF_HASH, :key2, 40) }.to raise_error
    end
  end
end
