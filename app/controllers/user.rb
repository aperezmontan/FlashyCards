get '/user/new' do
  erb :"user/new"
end


post '/user/new' do
 new_user = User.new(name: params[:name], password: params[:password])
 
 #ZM: What Happens if the user save does not work?
 new_user.save
 redirect "/"
end
