require "pyroscope"

class ApplicationController < ActionController::Base
  include Pagy::Backend
  before_action :authenticate_user!
  before_action :set_paper_trail_whodunnit
  before_action :set_current_user
  around_action :add_pyroscope

  helper_method def current_organization
    current_user.organization
  end

  def authorize_admin!
    redirect_to root_path, alert: "Not authorized" unless current_user.admin?
  end

  # Auth check for Blazer reporting
  def require_organization
    redirect_to root_path unless current_user && current_organization
  end

  # Save current_user to a place Blazer and models can access it.
  def set_current_user
    Current.user = current_user
  end

  # Blazer's before_action_method call to
  # make sure a user is logged in and associated
  # with an organizatio as the app does.
  def blazer_setup
    require_organization
    set_current_user
  end

  # Error page for CanCanCan
  rescue_from CanCan::AccessDenied do
    flash[:alert] = 'You are not authorized to access this resource.'
    redirect_back fallback_location: root_path, status: 302
  end

  private

  def add_pyroscope    
    tags = {
      "controller": controller_name,
      "action": action_name,
      "user_id": current_user&.id || "none",
      "organization_id": current_user&.organization&.id || "none"
    }

    Pyroscope.tag_wrapper(tags) do 
      yield
    end
  end
end
