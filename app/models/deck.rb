class Deck < ActiveRecord::Base

  serialize :cards, JSON


  def Deck::create_decks(number,shuffled,jokers)
    deck_ids = []
    final_value = 52
    if jokers.to_s == "on"
      final_value = 54
    end
    for deck in 1..number.to_i
      cards = []
      for card in 1..final_value do
        cards.append(card)
      end
      if shuffled.to_s == "on"
        curr_deck = create!({:cards => cards.shuffle, :top_card_showed => false})
      else
        curr_deck = create!({:cards => cards, :top_card_showed => false})
      end
      deck_ids.append(curr_deck.id)
    end
    return deck_ids
  end

  def Deck::create_sinks(number,show_discard)
    show = true
    if show_discard == "off"
      show= false
    end

    deck_ids = []
    for deck in 1..number.to_i
      curr_deck = create!({:cards => [], :top_card_showed => show})
      deck_ids.append(curr_deck.id)
    end
    return deck_ids
  end

  def self.cards(id)
    Deck.where(id: id).first[:cards]
  end
end




