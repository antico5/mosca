require 'command_builder'

class Freezer
  include CommandBuilder

  attr_accessor :client, :id

  def initialize args
    @client = args[:client]
    @id = args[:freezer_id]
  end

  def default_hash
    {freezer_id: @id,
     user_id: "",
     body: {},
     admin: false}
  end

  def process_command command, args
    {command: command}
  end

  def admin_lock_hash status
    {admin: true,
    body: status}
  end

end
