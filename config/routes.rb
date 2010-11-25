FatFreeCRM::Application.routes.draw do

  match '/:controller/tagged/:id' => '#tagged'
end
