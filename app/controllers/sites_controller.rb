class SitesController < ApplicationController
  before_action :set_site, only: %i[ edit update destroy ]
  before_action :require_role

  def require_role
    unless current_user&.role == true
      redirect_to root_path, alert: "Accès non autorisé."
    end
  end

  # GET /sites or /sites.json
  def index
    @sites = Site.all
  end

  # GET /sites/new
  def new
    @site = Site.new
  end

  # GET /sites/1/edit
  def edit
  end

  # POST /sites or /sites.json
  def create
    @site = Site.new(site_params)
  
    respond_to do |format|
      if @site.save

    # Création du nom de la mailing list en utilisant le nom du site
    mailing_list_name = "Mailing List " + @site.name

    # Création de la mailing list associée au site
    @mailing_list = @site.mailing_lists.create(name: mailing_list_name)

    # Mise à jour du texte générique de la mailing list
    generic_text = "Vous recevez ce mail parce que vous êtes inscrit à la mailing list \"#{Rails.application.config.settings.appname}\". Voici les prochaines disponibilités du site #{@site.name}. Modifiez vos préférences directement sur votre compte."
    @mailing_list.update(text: generic_text)
 

        format.html { redirect_to site_url(@site), notice: "Le site a bien été créé !" }
        format.json { render :show, status: :created, location: @site }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @site.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /sites/1 or /sites/1.json
  def update
    respond_to do |format|
      if @site.update(site_params)
        format.html { redirect_to site_url(@site), notice: "Le site a bien été modifié !" }
        format.json { render :show, status: :ok, location: @site }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @site.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sites/1 or /sites/1.json
  def destroy
    @site.destroy

    respond_to do |format|
      format.html { redirect_to sites_url, notice: "Le site a bien été supprimé !" }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_site
      @site = Site.find(params[:id])
    end

    def set_cdom_name
      @site = Site.find(params[:id])
      @cdom_name = @site.cdom.name
    end

    # Only allow a list of trusted parameters through.
    def site_params
      params.require(:site).permit(:name, :address, :postal_code, :city, :software, :informations, :cdom_id, :color, :min_patients, :max_patients, :min_patients_helped, :max_patients_helped, :am_min_hour, :am_max_hour, :pm_min_hour, :pm_max_hour)
    end
end
