class PartiesController < ApplicationController
  before_action :set_party, only: [:show, :edit, :update, :destroy]

  # GET /parties
  # GET /parties.json
  def index
    @parties = Party.all
  end

  # GET /parties/1
  # GET /parties/1.json
  def show
      party_id = params[:id]
      @user = User.find(params[:user_id])
      @songs = [] 
      @party_songs = @party.party_songs

      #have the song ids in the correct order here
      @party_songs = @party_songs.sort_by {|ps| ps.votes }.reverse!

      @party_songs.each do |ps|  
        song = Song.find(ps.song_id)
        @songs << song
      end
  end

  # GET /parties/new
  def new
    @user = User.find(params[:user_id]);
    @party = Party.new
  end

  # GET /parties/1/edit
  def edit
  end

  # POST /parties
  # POST /parties.json
  def create
    @party = Party.new(name: params[:party][:name])
    @user = User.find(params[:party][:user_id])

    respond_to do |format|
      if @party.save
          #If successful we need to also create a party_users entry and 
          #also a party_songs entry
          
          #create a party_user
          new_party_user = PartyUser.create(party_id: @party.id, user_id: @user.id)
          new_party_user.save!

          #for now, redirect to this party's page. Possibly have an intermediate 
          #Make the playlist page here instead? 
          format.html { redirect_to new_party_song_path(:party_id => @party.id, :user_id => @user.id), notice: 'Party was successfully created.' }
          format.json { render :show, status: :created, location: @party }
      else
        format.html { render :new }
        format.json { render json: @party.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /parties/1
  # PATCH/PUT /parties/1.json
  def update
    respond_to do |format|
      if @party.update(party_params)
        format.html { redirect_to @party, notice: 'Party was successfully updated.' }
        format.json { render :show, status: :ok, location: @party }
      else
        format.html { render :edit }
        format.json { render json: @party.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /parties/1
  # DELETE /parties/1.json
  def destroy
    @party.destroy
    respond_to do |format|
      format.html { redirect_to parties_url, notice: 'Party was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def add_song
    title = params[:title]
    artist = params[:artist]
    user_id = params[:user_id]
    party_id = params[:party_id]

    @user = User.find(user_id)
    @party = Party.find(party_id)

    #check if song is in the database
    #if it isn't add it to Songs
    #Create a songs method that will do this for us

    song = Song.add_song(artist, title)

    #add a party_songs record no matter what
    new_party_songs = PartySong.create(party_id: party_id, song_id: song.id)
    new_party_songs.save!

    #redirect back to the user's party page to see the new song show up
    redirect_to user_party_path(@user, @party)
  end

  #route used to remove yourself from the current party
  def leave_party
    user_id = params[:user_id]
    @user = User.find(user_id)
    party_id = params[:party_id]
    @party = Party.find(party_id)
    
    @user.parties.delete(@party)

    redirect_to @user
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_party
      @party = Party.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def party_params
      params.require(:party).permit(:name, :user_id)
    end
end
