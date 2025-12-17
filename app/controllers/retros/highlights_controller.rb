class Retros::HighlightsController < ApplicationController
  before_action :set_retro
  before_action :ensure_participant
  before_action :ensure_admin

  def update
    user_id = params[:user_id].to_i
    new_value = @retro.highlighted_user_id == user_id ? nil : user_id

    @retro.update!(highlighted_user_id: new_value)
    broadcast_highlight(new_value)

    head :ok
  end

  def destroy
    @retro.update!(highlighted_user_id: nil)
    broadcast_highlight(nil)

    head :ok
  end

  private

  def set_retro
    @retro = Current.account.retros.find(params[:retro_id])
  end

  def ensure_participant
    redirect_to retros_path unless @retro.participant?(Current.user)
  end

  def ensure_admin
    head :forbidden unless @retro.admin?(Current.user)
  end

  def broadcast_highlight(user_id)
    Turbo::StreamsChannel.broadcast_action_to(
      @retro,
      action: :highlight,
      attributes: { "user-id": user_id.to_s }
    )
  end
end
