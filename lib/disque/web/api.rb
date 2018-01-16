require 'grape'
require 'disque/fancy_client'

module Disque::Web
  class API < Grape::API
    prefix :api

    content_type :json, 'application/html; charset=utf-8'
    content_type :html, 'text/html; charset=utf-8'
    default_format :json

    class << self
      def disque_client
        disque_reconnect! unless @disque_client
        @disque_client
      end

      def disque_reconnect!
        @disque_client ||= Disque::FancyClient.new(ENV['DISQUE_ADDRS'] || '127.0.0.1:7711')
      end
    end

    helpers do
      def disque_client
        API.disque_client
      end

      def disque_reconnect!
        API.disque_reconnect!
      end
    end

    resource :server do
      get :info do
        disque_client.info
      end
      put :reconnect do
        disque_reconnect!
        true
      end
    end

    resource :queues do
      get do
        disque_client.qscan.to_a
      end
      route_param :queue_name do
        get do
          disque_client.qstat params[:queue_name]
        end
        resource :jobs do
          get do
            disque_client.jscan(queue: params[:queue_name], reply: 'id').to_a
          end
        end
      end
    end

    resource :jobs do
      get do
        disque_client.jscan.to_a
      end
      route_param :job_id do
        get do
          disque_client.show params[:job_id]
        end
        delete do
          disque_client.deljob params[:job_id]
        end
        put :ack do
          disque_client.ackjob params[:job_id]
        end
      end
    end

  end # class API
end # module Disque::Web
