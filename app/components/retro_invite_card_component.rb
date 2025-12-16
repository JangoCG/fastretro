class RetroInviteCardComponent < ApplicationComponent
  def initialize(retro:)
    @retro = retro
  end

  def render?
    join_code.present?
  end

  def invite_url
    helpers.retro_invite_path(code: join_code, retro_id: @retro.id, script_name: nil)
  end

  def full_invite_url
    helpers.request.base_url + invite_url
  end

  private

  def join_code
    @retro.account.join_code&.code
  end
end
