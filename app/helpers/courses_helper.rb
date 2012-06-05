module CoursesHelper
  def schedule_table_cell(sch)
    puts "Schedule: #{sch}"
    schs = @course.schedules.select {|s| s.block[1,2] == sch}
    if schs.map {|s| s.block[0]}.include?("F") && schs.map {|s| s.block[0]}.include?("E")
      css_class = "allyear"
    elsif schs.map {|s| s.block[0]}.include?("F")
      css_class = "spring"
    elsif schs.map {|s| s.block[0]}.include?("E")
      css_class = "autumn"
    end
    if css_class.blank?
      "<td>#{sch}</td>".html_safe
    else
      "<td class=\"#{css_class}\"><strong>#{sch}</strong></td>".html_safe
    end
  end
  
  def season_text()
    if @course.schedules.map {|s| s.block[0]}.include?("F") && @course.schedules.map {|s| s.block[0]}.include?("E")
      I18n.translate('seasons.spring') + " " + I18n.translate('and') + " " + I18n.translate('seasons.autumn')
    elsif @course.schedules.map {|s| s.block[0]}.include?("F")
      I18n.translate('seasons.spring')
    elsif @course.schedules.map {|s| s.block[0]}.include?("E")
      I18n.translate('seasons.autumn')
    end
  end
end
