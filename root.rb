require 'sinatra/base'

class Root < Sinatra::Base
  enable :inline_templates

  get '/' do
    erb :root
  end
end

__END__

@@root

<div style="text-align: center;">
  <a class="button" href="/m/">Matches</a>
  <a class="button" href="/qm/">Quick Match</a>
</div>
