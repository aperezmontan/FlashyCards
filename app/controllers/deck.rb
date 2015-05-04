get '/deck/new' do
   #ZM: Fix indentation to be only 2 spaces  
   #ZM: Remove nesting with redirect '/' unless current_user
   if current_user
     erb :"deck/new"
   else
    redirect '/'
   end
end

post '/deck/new' do
  #ZM: What happens if the deck does not save? 
  deck_1 = Deck.create(name: params[:name], user_id: session[:user_id])
  redirect "/deck/#{deck_1.id}/card/new"
end

get '/deck/:deckid/edit' do
  #ZM: Remove nesting with redirect '/' unless current_user
  if current_user
    deck = Deck.find_by(id: params[:deckid])
    erb :"deck/edit", locals: {deck_id: params[:deckid], deck_name: deck.name }
  else
    redirect '/'
  end
end

#ZM: var name :deck_id
put '/deck/:deckid/edit' do
  value = Deck.find_by(id: params[:deckid])

  #ZM: Don't use update_attributes if only changing one.
  value.update_attributes( name: params[:name])
  redirect "/deck_select"
end

delete '/deck/:deckid/edit' do
  deck_delete = Deck.find_by(id: params[:deckid])
  deck_delete.cards.destroy_all
  deck_delete.destroy
  redirect "/deck_select"
end

get '/deck/edit' do
  if current_user
    all_decks = Deck.where(user_id: current_user.id)
    erb :"deck/all_edit", locals: {all_decks: all_decks}
  else
    redirect '/'
  end
end

get '/deck_select' do

  #ZM: Reduce Nesting, redirect '/' unless current_user
  if current_user
    all_decks = Deck.all
    last_deck = all_decks.last
    live_rounds = Round.where(live:true, user_id: current_user.id).count

    #ZM: This logic belongds somewhere else... Maybe  a game Model?
    while live_rounds > 0
      round = Round.find_by(live:true, user_id: current_user.id)
      round.update_attributes(live: false)
      live_rounds = Round.where(live:true, user_id: current_user.id).count
    end

    #ZM: The 5 here is arbitrariy. Either Assign it to a constent, or provide comments for context. 
    #ZM: Maybe move this to the model too?
    if last_deck.cards.count < 5

      #ZM: Why are you destroying in this route? 
      last_deck.cards.destroy_all
      last_deck.destroy

      #ZM: This does not look very dry
      erb :"/deck/all", locals: {all_decks: all_decks, deck_select: true}
    else
      erb :"/deck/all", locals: {all_decks: all_decks, deck_select: false}
    end
  else
    redirect "/"
  end
end

get "/deck/:deckid/card/new" do
  if current_user

    erb :"card/new" ,locals: {deck_id: params[:deckid]}

  else
    redirect '/'
  end
end

post "/deck/:deckid/card" do
  new_card = Card.new(question: params[:question], answer: params[:answer], deck_id: params[:deckid])
  #ZM: What happens if the card does not save correctly 
  new_card.save
  redirect "/deck/#{params[:deckid]}/card/new"
end
