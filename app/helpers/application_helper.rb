# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def flashes
    if !flash[:notice].blank? || !flash[:warning].blank? || !flash[:error].blank?
      @flashes = "<div id=\"flashes\">"
      @flashes += flash[:notice].blank? ? "" : '<p class="flash_notice"><span>' + flash[:notice] + '</span></p>'
      @flashes += flash[:warning].blank? ? "" : '<p class="flash_warning"><span>' + flash[:warning] + '</span></p>'
      @flashes += flash[:error].blank? ? "" : '<p class="flash_error"><span>' + flash[:error] + '</span></p>'
      @flashes + "</div>"
    end
  end
  
end
