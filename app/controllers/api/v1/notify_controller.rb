module Api
  module V1
    class NotifyController < ActionController::API
      # POST api/v1/notify
      def create
        Authentication.process(params)

        head(:created)
      end
    end
  end
end

