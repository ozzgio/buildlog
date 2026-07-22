class EntriesController < ApplicationController
  allow_unauthenticated_access only: %i[ index show ]

  before_action :set_entry, only: :show

  def index
    @entries = Entry.all

    respond_to do |format|
      format.html
      format.rss { render layout: false }
    end
  end

  def show
  end

  def new
    @entry = Entry.new
  end

  def create
    @entry = Entry.new(entry_params)

    if @entry.save
      redirect_to entries_path, notice: "Entry posted."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
    def set_entry
      @entry = Entry.find(params[:id])
    end

    def entry_params
      params.require(:entry).permit(:body, :link)
    end
end
