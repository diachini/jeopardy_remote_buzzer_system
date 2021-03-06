class MessagesController < ApplicationController
  before_action :set_message, only: [:show, :edit, :update, :destroy]

  # GET /messages
  # GET /messages.json
  def index
    @messages = Message.all
  end

  # GET /messages/1
  # GET /messages/1.json
  def show
  end

  # GET /messages/new
  def new
    @message = Message.new
  end

  # GET /messages/1/edit
  def edit
  end

  # POST /messages
  # POST /messages.json
  def create
    @message = Message.new(message_params)

    respond_to do |format|
      if @message.save
        button_pressed =
          case params[:commit]
          when 'Ring In'
            'rang in'
          when 'Check In'
            'is in the house'
          when 'Allow Responses'
            'opened responses'
          when 'Reset'
            'reset responses'
          else
            'hacked the gibson'
          end
        sleep_time_delay = ""
        if params[:commit] == 'Allow Responses'
          sleep_time = 300 + rand(400)  # random delay in ms
          sleep_time_delay = "(#{sleep_time}ms delay)"
          sleep( sleep_time / 1000.0 )
        end
        formatted_message = "<b>#{@message.sender}</b> #{button_pressed} #{sleep_time_delay} at: "
        ActionCable.server.broadcast 'web_notifications_channel',
          message: formatted_message,
          time: Time.zone.now,
          message_type: params[:commit]
        format.html { redirect_to @message, notice: 'Message was successfully created.' }
        format.json { render :show, status: :created, location: @message }
        format.js { head :no_content}
      else
        format.html { render :new }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /messages/1
  # PATCH/PUT /messages/1.json
  def update
    respond_to do |format|
      if @message.update(message_params)
        format.html { redirect_to @message, notice: 'Message was successfully updated.' }
        format.json { render :show, status: :ok, location: @message }
      else
        format.html { render :edit }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /messages/1
  # DELETE /messages/1.json
  def destroy
    @message.destroy
    respond_to do |format|
      format.html { redirect_to messages_url, notice: 'Message was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_message
      @message = Message.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def message_params
      params.require(:message).permit(:sender)
    end
end
