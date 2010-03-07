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
  
  def options_from_hash_for_select(collection, value_method, text_method, selected = nil)              
    options = collection.map do |element|
      [eval("element['#{text_method}']"), eval("element['#{value_method}']")]                          
    end
    options_for_select(options, selected)
  end
  
end
