FROM internetee/ruby:2.7

# RUN apt-get update && apt-get upgrade -y && \
#    apt-get install -y nodejs \
#    npm

RUN npm install -g yarn@latest

WORKDIR /opt/webapps/app

COPY Gemfile Gemfile.lock ./

# ADD vendor/gems/omniauth-tara ./vendor/gems/omniauth-tara
# ADD vendor/gems/omniauth ./vendor/gems/omniauth

RUN gem install bundler && bundle install --jobs 20 --retry 5

COPY package.json yarn.lock ./

RUN yarn install --check-files

EXPOSE 3000
