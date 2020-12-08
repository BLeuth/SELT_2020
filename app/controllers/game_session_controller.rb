class GameSessionController < ApplicationController

  def hash_return(cards,shown)
    @card_value = {#Back of card
                   0 => "&#127136",
                   #Spades
                   1 => "&#127137",
                   2 => "&#127138",
                   3 => "&#127139",
                   4 => "&#127140",
                   5 => "&#127141",
                   6 => "&#127142",
                   7 => "&#127143",
                   8 => "&#127144",
                   9 => "&#127145",
                   10 => "&#127146",
                   11 => "&#127147",
                   12 => "&#127149",
                   13 => "&#127150",
                   #Hearts
                   14 => "&#127153",
                   15 => "&#127154",
                   16 => "&#127155",
                   17 => "&#127156",
                   18 => "&#127157",
                   19 => "&#127158",
                   20 => "&#127159",
                   21 => "&#127160",
                   22 => "&#127161",
                   23 => "&#127162",
                   24 => "&#127163",
                   25 => "&#127165",
                   26 => "&#127166",
                   #Diamonds
                   27 => "&#127169",
                   28 => "&#127170",
                   29 => "&#127171",
                   30 => "&#127172",
                   31 => "&#127173",
                   32 => "&#127174",
                   33 => "&#127175",
                   34 => "&#127176",
                   35 => "&#127177",
                   36 => "&#127178",
                   37 => "&#127179",
                   38 => "&#127181",
                   39 => "&#127182",
                   # Clubs
                   40 => "&#127185",
                   41 => "&#127186",
                   42 => "&#127187",
                   43 => "&#127188",
                   44 => "&#127189",
                   45 => "&#127190",
                   46 => "&#127191",
                   47 => "&#127192",
                   48 => "&#127193",
                   49 => "&#127194",
                   50 => "&#127195",
                   51 => "&#127197",
                   52 => "&#127198",
                   53 => "&#127169", #This is a red joker
                   54 => "&#127183", #This is a black joker
                   55 => "&#127148",#This is a knight of spades
                   56 => "&#127164", #This is a knight of hearts
                   57 => "&#127180", #This is a knight of diamonds
                   58 => "&#127196", #This is a knight of clubs

    }
    user_hand_card_values = {}
    cards.each do |i|
      if shown
        if i == 53 or (i >=14 and i <= 39)
          user_hand_card_values[i] = "R"+@card_value[i]
        else
          user_hand_card_values[i]= "B"+@card_value[i]
        end
      else
        user_hand_card_values[i]= "B"+@card_value[0]
      end
    end

    return user_hand_card_values
  end

  def index
    unless @current_game.first
      redirect_to games_path
    end
  end

  def new
    game_id = @current_user.select(:current_game).first.attributes.values[1]
    Cardgame.where(game_id: game_id).update_all(started: true)
    redirect_to game_session_path(game_id)
  end

  #TODO: MAKE THE WEBPAGE REFRESH
  def show
    unless @current_game.first
      redirect_to games_path
      return
    end
    @sinks = @current_game.select(:discard_ids).first.attributes.values[1]
    @sinkHashes = []
    @sinks.each do |sink|
      hash = {}
      hash[:id] = sink
      hash = hash.merge(hash_return(Deck.where(id: sink).pluck(:cards)[0],true))
      @sinkHashes.append(hash)
    end

    puts "MATT" + @sinkHashes.to_s

    @decks = @current_game.select(:deck_ids).first.attributes.values[1]
    @deckHashes = []
    @decks.each do |deck|
        deck_top_card = Deck.where(id: deck).pluck(:top_card_showed)[1]
        hash = {}
        hash[:id] = deck
        hash = hash.merge(hash_return(Deck.where(id: deck).pluck(:cards)[0],deck_top_card))
        @deckHashes.append(hash)
    end

    puts "MATT" + @deckHashes.to_s

    user_id = @current_user.select(:id).first.attributes.values[0]
    @user_hand_card_values = hash_return(Hand.where(user_id: user_id).select(:cards).first.attributes.values[1],true)
    @user_id_list = @current_game.first.user_ids
    @user_cards_hash = {}
    @user_id_list.each do |other_user_id|
      username = User.where(id: other_user_id).pluck(:username)[0]
      cards = hash_return(Hand.where(user_id: other_user_id).select(:cards).first.attributes.values[1],true)
      @user_cards_hash[other_user_id] = { :username => username, :cards => cards }
    end

    @table = hash_return(@current_game.pluck(:table)[0],true)
  end


  def destroy
    # Check that the user is still in a game
    if @current_user.select(:current_game).first.attributes.values[1] != 0
      game_id = @current_user.select(:current_game).first.attributes.values[1]
      row_id = @current_game.pluck(:id)
      deck_ids = Cardgame.where(id: row_id).pluck(:deck_ids)[0].concat(Cardgame.where(id: row_id).pluck(:discard_ids)[0])
      hand_ids = Cardgame.where(id: row_id).pluck(:hand_ids)[0]

      if @current_game.first
        user_ids = Cardgame.user_ids(game_id)
        User.where(id: user_ids).update_all(current_game: 0)
        Cardgame.where(game_id: game_id).update_all(started: false )
      end

      Cardgame.delete(row_id)
      deck_ids.each do |id|
        Deck.delete(id)
      end
      hand_ids.each do |id|
        Hand.delete(id)
      end

      user_ids.each do |id|
        User.where(id: id).update_all(current_game: 0)
      end
    end
    redirect_to games_path
    flash[:notice] = "One of the user ended the game"
  end

  def update
    # TODO: logic to move card from one user to the other
    # Need to fix the card from unicode to id
    # Location 0 is the function. each one after that is the params
    user_id = @current_user.select(:id).first.attributes.values[0]
    game_id = @current_user.select(:current_game).first.attributes.values[1]
    apiHelper = ApiHelper.new(request.original_url)
    game_id = @current_user.select(:current_game).first.attributes.values[1]

    if apiHelper.function == 'moveCard'
      # TODO
      # Right now we are assuming that the card being moved is coming from a user's hand. We need to check to see what the
      # source of the move is and update that database table accordingly
      # Alternative -- Just draw a card and it will append the last card of the deck to the user's hand.
      # Further details ask Mathew

      current_user_cards =Hand.where(user_id: user_id).select(:cards).first.attributes.values[1]
      current_user_cards.delete(apiHelper.parameters['card'].to_i)
      Hand.where(user_id: user_id).update_all(cards: current_user_cards)

      # Move card to table
      if apiHelper.parameters['dest'] == 'table'
        table = @current_game.pluck(:table)[0]
        table.append(apiHelper.parameters['card'].to_i)
        Cardgame.where(game_id: game_id).update_all(table: table)

      # Move card to sink
      elsif apiHelper.parameters['dest'].include?('sink')
        sinkID = apiHelper.parameters['dest'].gsub('sink_', '')
        current_cards_in_sink = Deck.where(id: sinkID).select(:cards).first.attributes.values[1]
        current_cards_in_sink.append(apiHelper.parameters['card'].to_i)
        Deck.where(id: sinkID).update_all(cards: current_cards_in_sink)

      # Move Card to other users hand
      else
        other_user_id = User.where(username: apiHelper.parameters['dest']).select(:id).first.attributes.values[0]
        other_user_cards =Hand.where(user_id: other_user_id).select(:cards).first.attributes.values[1]
        other_user_cards.append(apiHelper.parameters['card'].to_i)
        Hand.where(user_id: other_user_id).update_all(cards: other_user_cards)
      end

    elsif apiHelper.function == 'moveCardDraw'
      current_cards_from_draw = Deck.where(id: apiHelper.parameters['source']).pluck(:cards)[0]
      current_picked_card = current_cards_from_draw.last
      current_cards_from_draw.delete(current_cards_from_draw.last)
      Deck.where(id: apiHelper.parameters['source']).update_all(cards: current_cards_from_draw)

      if apiHelper.parameters['dest'] == 'table'
        table = @current_game.pluck(:table)[0]
        table.append(current_picked_card)
        Cardgame.where(game_id: game_id).update_all(table: table)

      elsif apiHelper.parameters['dest'].include?('sink')
        sinkID = apiHelper.parameters['dest'].gsub('sink_', '')
        current_cards_in_sink = Deck.where(id: sinkID).select(:cards).first.attributes.values[1]
        current_cards_in_sink.append(current_picked_card)
        Deck.where(id: sinkID).update_all(cards: current_cards_in_sink)

      elsif apiHelper.parameters['dest'].include?('draw')
        draw_id = apiHelper.parameters['dest'].gsub('draw_', '')
        current_cards_in_draw = Deck.where(id: draw_id).select(:cards).first.attributes.values[1]
        current_cards_in_draw.append(current_picked_card)
        Deck.where(id: draw_id).update_all(cards: current_cards_in_draw)

      else
        target_user_id = User.where(username: apiHelper.parameters['dest']).select(:id).first.attributes.values[0]
        target_user_cards = Hand.where(user_id: target_user_id).select(:cards).first.attributes.values[1]
        target_user_cards.append(current_picked_card)
        Hand.where(user_id: target_user_id).update_all(cards: target_user_cards)
      end

    elsif apiHelper.function == 'moveCardTable'
      current_table_cards = Cardgame.table(game_id)
      current_table_cards.delete(apiHelper.parameters['card'].to_i)
      Cardgame.where(game_id: game_id).update_all(table: current_table_cards)

      if apiHelper.parameters['dest'].include?('sink')
        sink_id = apiHelper.parameters['dest'].gsub('sink_', '')
        current_cards_in_sink = Deck.where(id: sink_id).select(:cards).first.attributes.values[1]
        current_cards_in_sink.append(apiHelper.parameters['card'].to_i)
        Deck.where(id: sink_id).update_all(cards: current_cards_in_sink)

      else
        user_id = User.where(username: apiHelper.parameters['dest']).select(:id).first.attributes.values[0]
        current_user_cards = Hand.where(user_id: user_id).select(:cards).pluck(:cards)[0]
        current_user_cards.append(apiHelper.parameters['card'].to_i)
        Hand.where(user_id: user_id).update_all(cards: current_user_cards)

      end

    elsif apiHelper.function == 'leaveGame'
      current_user_cards = Hand.where(user_id: user_id).select(:cards).first.attributes.values[1]

      if current_user_cards.size == 0
        user_ids = Cardgame.user_ids(game_id)
        hand_ids = Cardgame.hand_ids(game_id)
        hand_id = Hand.where(user_id: user_id).select(:id).first.attributes.values[0]

        user_ids.delete(user_id)
        hand_ids.delete(hand_id)

        Cardgame.where(id: @current_game.pluck(:id)).update_all(user_ids: user_ids)
        Cardgame.where(id: @current_game.pluck(:id)).update_all(hand_ids: hand_ids)
        Hand.delete(hand_id)
        User.where(id: user_id).update_all(current_game: 0)
        redirect_to games_path
        return
      else
        flash[:notice] = 'Please discard the cards in your hand to leave the game'
      end

    elsif apiHelper.function == 'resetGame'
      # TODO: Reset the game to random initial state

    elsif apiHelper.function == 'shuffle'
      deck_id = apiHelper.parameters['deck'].to_i
      deck = Deck.where(id: deck_id).pluck(:cards)[0]
      deck = deck.shuffle
      Deck.where(id: deck_id).update_all(cards: deck)

    end

    redirect_to game_session_path(game_id)
  end
end

class ApiHelper
  attr_reader :function,:parameters
  def initialize(url)
    data = url.split(/([^.]+$)/)[1].split('&')
    @function = data[0].split('=')[1]
    @parameters = {}
    data.each_with_index do |elem, i|
      if i != 0
        info = elem.split('=')
        @parameters[info[0]] = info[1]
      end
    end
  end
end


