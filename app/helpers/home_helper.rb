module HomeHelper
  # Logged out (search field)
  
  # Logged in (schedule)
  def schedule_table_cell(sch)
    css_class = ""
#    schs = @course.schedules.select {|s| s.block[1,2] == sch}
#    if schs.map {|s| s.block[0]}.include?("F") && schs.map {|s| s.block[0]}.include?("E")
#      css_class = "allyear"
#    elsif schs.map {|s| s.block[0]}.include?("F")
#      css_class = "spring"
#    elsif schs.map {|s| s.block[0]}.include?("E")
#      css_class = "autumn"
#    end
    if css_class.blank?
      "<td>#{sch}</td>".html_safe
    else
      "<td class=\"#{css_class}\"><strong>#{sch}</strong></td>".html_safe
    end
  end
end
