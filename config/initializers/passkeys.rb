Rails.application.config.action_pack.passkey.draw_routes = false
Rails.application.config.action_pack.passkey.challenge_url = -> { my_passkey_challenge_path(script_name: "") }
