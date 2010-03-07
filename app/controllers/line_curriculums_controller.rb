class LineCurriculumsController < ApplicationController
  
  def find_place
    params.each do |name, value|
      if name =~ /(.+)_id$/
        return $1.classify.constantize.find(value)
      end
    end
  end
  
end
