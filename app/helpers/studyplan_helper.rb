module StudyplanHelper
	TOTAL_ECTS_GOAL = 180
	
	def ects_points_block_progress(points)
		points / (TOTAL_ECTS_GOAL/4)
	end
	def ects_points_block_percentage(points)
		(self.ects_points_block_progress(points) * 100).round(2)
	end
end
