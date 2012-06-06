module StudentHelper
  def student_schedule_table_cell(schedule)
    "<td><strong>#{schedule}</strong></td>".html_safe
  end
end
