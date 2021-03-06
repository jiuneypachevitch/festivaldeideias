ActiveAdmin.register IdeaCategory do
  menu :label => "Categorias"


  index do
    column :id
    column :badge do |s|
      image_tag s.badge, :size => "31x31"
    end
    column :pin do |s|
      image_tag s.pin
    end
    column :name
    column "Criado em" do |s|
      s.created_at.strftime('%d/%m/%Y')
    end
    column "Atualizado" do |s|
      s.updated_at.strftime('%d/%m/%Y')
    end
    default_actions
  end

  form do |f|
    f.inputs "Details" do
      f.input :name, :as => :string
      f.input :description, :as => :string
    end
    f.inputs "Imagens" do
      f.input :badge, :as => :file
      f.input :pin, :as => :file
    end
    f.buttons
  end
end
