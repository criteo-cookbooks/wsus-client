module WsusClient
  # Provide some convenient helper methods
  module Helper
    INSTALL_DAYS = %w(
      every_day
      sunday
      monday
      tuesday
      wednesday
      thursday
      friday
      saturday
    ) unless defined? WsusClient::Helper::INSTALL_DAYS

    def self.get_install_day(node_value)
      INSTALL_DAYS.index(node_value.to_s) ||
        fail("Invalid 'schedule_install_day' value of '#{node_value}'")
    end

    def self.get_behavior(node_value)
      case node_value.to_s
      when 'disabled'  then 1
      when 'detect'    then 2
      when 'download'  then 3
      when 'install'   then 4
      when 'manual'    then 5
      else fail "Invalid 'automatic_update_behavior' value of '#{node_value}'"
      end
    end

    def self.check_limit(hash, key, limit)
      value = hash[key]
      fail "Invalid '#{key}' value of '#{value}'" if value > limit || value < 0
    end
  end
end
