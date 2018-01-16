require 'disque'
require 'disque/client'
require 'grape-entity'

class Disque::Cluster
  include Grape::Entity::DSL

  attr_reader :id, :addrs, :client

  def self.list_from_env
    ENV['DISQUE_ADDRS'].split(',,').each_with_index.map do |cluster_addrs, cluster_index|
      self.new cluster_index, cluster_addrs.split(',')
    end
  end

  def initialize(id = 0, addrs = [])
    @id, @addrs = id, addrs
    @client = Disque::Client.new addrs
  end

  entity do
    expose :id
    expose :addrs
  end
end
