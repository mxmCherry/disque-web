require 'disque'
require 'disque/cluster'
require 'grape'
require 'grape-entity'

module Disque::Web
  class Api < Grape::API
    prefix :api
    format :json

    class << self
      def cluster_list
        @cluster_list ||= Disque::Cluster.list_from_env
      end

      def cluster_index
        @cluster_index ||= Hash[
          *cluster_list.map{ |c| [c.id, c] }.flatten
        ]
      end
    end

    helpers do
      def cluster_list
        Api.cluster_list
      end

      def cluster_index
        Api.cluster_index
      end

      def cluster
        cluster_index[params[:cluster_id]]
      end
    end

    resource :clusters do
      get do
        present cluster_list
      end

      params do
        requires :cluster_id, type: Integer
      end
      route_param :cluster_id do
        get do
          present addrs: cluster.addrs, info: cluster.client.info
        end

        resource :queues do
          get do
            present cluster.client.qscan.lazy.map{ |name| { name: name } }.to_a
          end

          params do
            requires :queue_name, type: String
          end
          route_param :queue_name do
            get do
              present cluster.client.qstat params[:queue_name]
            end

            resource :jobs do
              get do
                present cluster.client
                  .jscan(queue: params[:queue_name], reply: 'id').lazy
                  .map { |id| { id: id } }
                  .to_a
              end
            end
          end
        end

        resource :jobs do
          # get do
          #   present cluster.client
          #     .jscan(reply: 'id').lazy
          #     .map{ |id| { id: id } }
          #     .to_a
          # end

          params do
            requires :job_id, type: String
          end
          route_param :job_id do
            get do
              present cluster.client.show params[:job_id]
            end
            delete do
              present cluster.client.deljob params[:job_id]
            end
            put :ack do
              present cluster.client.ackjob params[:job_id]
            end
          end
        end
      end
    end

  end
end
