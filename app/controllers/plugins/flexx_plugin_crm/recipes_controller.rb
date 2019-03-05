module Plugins::FlexxPluginCrm
  class RecipesController < Plugins::FlexxPluginCrm::ApplicationController
    layout "layouts/flexx_next_admin"

    def index
      @active_task_recipes = current_site.task_recipes.active.order(:title)      
      @paused_task_recipes = current_site.task_recipes.paused.order(:title)

      @shared_recipes = TaskRecipe.where.not(site_id: current_site.id).order(:created_at)
      @shared_task_recipes = @shared_recipes.shared
      # @shared_task_recipes = @shared_recipes.group_by(&:title).map{|k, v| v.first}
      
    end

    def show
      @task_recipe = current_site.task_recipes.find(params[:id])
      @available_contact_forms = current_site.
                                  contact_forms.
                                  select(:id, :name).
                                  where(parent_id: nil).
                                  order(:name)
    end

    def create
      params[:task_recipe].merge!(created_by: current_user.id, shared: false)

      new_task_recipe = current_site.task_recipes.create(task_recipe_params)

      redirect_to action: :show, id: new_task_recipe.id
    end

    def toggle
      @task_recipe = current_site.task_recipes.find(params[:recipe_id])

      @task_recipe.update(paused: !@task_recipe.paused,
                          paused_by: !@task_recipe.paused ? current_user.id : nil,
                          paused_at: !@task_recipe.paused ? Time.current : nil)

      respond_to do |format|
        format.js
      end
    end

    def share
      @task_recipe = current_site.task_recipes.find(params[:recipe_id])

      @task_recipe.update(shared: !@task_recipe.shared,
                          shared_by: !@task_recipe.shared ? current_user.id : nil,
                          shared_at: !@task_recipe.shared ? Time.current : nil)

      respond_to do |format|
        format.js
      end
    end

    def add_shared
      @shared_recipe = TaskRecipe.find(params[:recipe_id])

      new_task_recipe = current_site.task_recipes.create(title: @shared_recipe.title,
                                                          description: @shared_recipe.title,
                                                          site_id: current_site.id,
                                                          created_by: current_user.id,
                                                          shared: false,
                                                          original_site_id: @shared_recipe.site_id,
                                                          updated_at: Time.current)
                        
      tasks = TaskRecipeDirection.where(task_recipe_id: @shared_recipe.id)

      tasks.each do |task|
        task_dup = task.dup
        task_dup.task_recipe_id = new_task_recipe.id;
        task_dup.save!
      end
      
      redirect_to action: :index
    end

    def destroy
      current_site.task_recipes.find(params[:id]).update!(
        archived: true,
        archived_by: current_user.id,
        archived_at: Time.current
      )

      redirect_to action: :index
    end

    def create_direction
      @task_recipe = current_site.task_recipes.find(params[:recipe_id])

      params[:task_recipe_direction].merge!(created_by: current_user.id)

      @task_recipe.directions.create(task_recipe_direction_params)

      respond_to do |format|
        format.js
      end
    end

    def destroy_direction
      Plugins::FlexxPluginCrm::TaskRecipeDirection.find(params[:id]).destroy
      redirect_to admin_recipe_path(params[:recipe_id])
    end

    private

    def task_recipe_params
      params.require(:task_recipe).permit(:title, :description, :created_by, :shared)
    end

    def task_recipe_direction_params
      params.require(:task_recipe_direction).permit(:task_type, :due_on_value, :due_on_unit, :title, :details, :created_by)
    end
  end
end
