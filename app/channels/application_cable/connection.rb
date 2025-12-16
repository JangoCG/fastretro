module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_identity

    def connect
      set_current_identity || reject_unauthorized_connection
    end

    private
      def set_current_identity
        if session = Session.find_signed(cookies.signed[:session_token])
          self.current_identity = session.identity
        end
      end
  end
end
