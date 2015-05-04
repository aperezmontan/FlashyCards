#ZM: Generally Speaking, this route is to big. It needs broken up, and some of it's logic can be pushed into models to provide more clairty.

get '/card/:card_id' do

  #ZM: First invert your if statement to remove nesting. 
  # redirect "/" unless current_user
  if current_user
    guessed_cards = []

    deck = Deck.find(params[:current_deck_id])

    #AF: Depricated... 
    #AF: Round.where(critera).first_or_create
    round = Round.find_or_create_by(live: true, deck_id: params[:current_deck_id], user_id: current_user.id)
   
    #ZM: This is a pretty messy, could be made more simple by using a select, or pluck statement.
    #guessed_cards = Guess.where(id: round.guess_ids).pluck(:card_id)
    Guess.where(id: round.guess_ids).each do |guess|
      guessed_cards << guess.card_id
      #ZM: Do not leave debug statements in your code.
      p guessed_cards
    end

    card_array = deck.card_ids - guessed_cards

    #ZM: Do not leave debug statements in your code.
    p card_array
   
    #ZM: Seems like this responsibility belongs somewhere else... Perhaps you need a Game Model? 
    if card_array.length == 0 || guessed_cards.count > 9
      round.update_attributes(live: 'false')
      redirect "/deck_select?round_over=true"
    end

    flash_card = Card.find(card_array.sample)

    #ZM: You should not need the .all.count here
    #AF: round.guesses.count || round.guesses.lenght
    guesses = round.guesses.all.count
    correct = 0
   
    #ZM: You should add a class method, or instance method that would return to you all the correct answers.  
    round.guesses.all.each do |guess|
      correct += 1 if guess.result
    end

    erb :"/card/show", locals:{flash_card: flash_card, correct: correct, guesses: guesses}
  else
    redirect "/"
  end


end

post '/card/:card_id' do
  card = Card.find(params[:card_id])
  round = Round.find_by(live: true, user_id: current_user.id)
  guess = Guess.create(round: round, card_id: params[:card_id], result: (card.answer.downcase == params[:answer].downcase))
  round.guesses << guess
  redirect "/card/#{params[:card_id]}?current_deck_id=#{card.deck_id}"
end
