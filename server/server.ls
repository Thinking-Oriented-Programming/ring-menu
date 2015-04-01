require! {express, http, path,}

app = express!

app.get '/api/random', (req, res)!-> 
  from = req.param 'from'
  set-timeout !->
    res.set 'Content-Type', 'text/plain'
    res.send '' + random = Math.floor Math.random! * 10
    console.log "Request from #{from}, answer random number: #{random}"
  , 1000ms + Math.random! * 2000ms



# server.listen host-config.end-server.port

exports = module.exports = app
