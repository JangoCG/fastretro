class RetrosController < ApplicationController
  include RetroAuthorization

  before_action :set_retro, only: %i[ show edit update destroy ]
  before_action :ensure_retro_participant, only: %i[ show ]
  before_action :ensure_retro_admin, only: %i[ edit update destroy ]

  # GET /retros or /retros.json
  def index
    @retros = Current.account.retros
  end

  # GET /retros/1 or /retros/1.json
  def show
    redirect_to phase_path_for(@retro)
  end

  # GET /retros/new
  def new
    @retro = Retro.new
  end


  # GET /retros/1/edit
  def edit
  end

  # POST /retros or /retros.json
  def create
    @retro = Current.account.retros.new(retro_params)

    respond_to do |format|
      if @retro.save
        @retro.add_participant(Current.user, role: :admin)
        format.html { redirect_to @retro, notice: "Retro was successfully created." }
        format.json { render :show, status: :created, location: @retro }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @retro.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /retros/1 or /retros/1.json
  def update
    respond_to do |format|
      if @retro.update(retro_params)
        format.html { redirect_to @retro, notice: "Retro was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @retro }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @retro.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /retros/1 or /retros/1.json
  def destroy
    @retro.destroy!

    respond_to do |format|
      format.html { redirect_to retros_path, notice: "Retro was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_retro
      @retro = Current.account.retros.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def retro_params
      params.expect(retro: [ :name ])
    end

    def phase_path_for(retro)
      case retro.phase.to_sym
      when :waiting_room then retro_waiting_room_path(retro)
      when :brainstorming then retro_brainstorming_path(retro)
      when :grouping then retro_grouping_path(retro)
      when :voting then retro_voting_path(retro)
      when :discussion then retro_discussion_path(retro)
      when :complete then retro_complete_path(retro)
      else retro_waiting_room_path(retro)
      end
    end
end
