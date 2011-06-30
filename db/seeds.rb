# coding: utf-8

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

site_template = Template.create! :name => "Idéia", :description => "Modelo simples para a colaboração na evolução de uma idéia."

site = Site.create! :name => "Festival de Idéias · Centro Ruth Cardoso", :host => "localhost", :port => "3000", :auth_gateway => true, :template => site_template

# TODO create a badge for each category with carrier wave
category_1 = Category.create! :site => site, :name => "Mobilidade urbana", :badge => "badge.png"
category_2 = Category.create! :site => site, :name => "Segurança comunitária", :badge => "badge.png"
category_3 = Category.create! :site => site, :name => "Catástrofes naturais", :badge => "badge.png"

user = User.create! :site => site, :provider => 'fake', :uid => 'foo_bar', :name => "Foo Bar"
user_2 = User.create! :site => site, :provider => 'fake', :uid => 'bar_foo', :name => "Bar Foo"

idea_1 = Idea.create! :site => site, :user => user, :category => category_1, :template => site.template, :title => "Circuito de webcams entre vizinhos", :headline => "Criar um sistema de monitoramento dos espaços públicos através de webcams que cada morador pode instalar."
idea_2 = Idea.create! :site => site, :user => user_2, :category => category_2, :template => site.template, :title => "Circuito de webcams entre vizinhos", :headline => "Criar um sistema de monitoramento dos espaços públicos através de webcams que cada morador pode instalar."
idea_3 = Idea.create! :site => site, :user => user, :category => category_3, :template => site.template, :title => "Circuito de webcams entre vizinhos", :headline => "Criar um sistema de monitoramento dos espaços públicos através de webcams que cada morador pode instalar."

Idea.create! :parent => idea_1, :site => site, :user => user_2, :category => category_1, :template => site.template, :title => "Circuito de webcams entre vizinhos", :headline => "Criar um sistema de monitoramento dos espaços públicos através de webcams que cada morador pode instalar."

Idea.create! :parent => idea_2, :site => site, :user => user, :category => category_2, :template => site.template, :title => "Circuito de webcams entre vizinhos", :headline => "Criar um sistema de monitoramento dos espaços públicos através de webcams que cada morador pode instalar."

Idea.create! :parent => idea_3, :site => site, :user => user_2, :category => category_3, :template => site.template, :title => "Circuito de webcams entre vizinhos", :headline => "Criar um sistema de monitoramento dos espaços públicos através de webcams que cada morador pode instalar."
