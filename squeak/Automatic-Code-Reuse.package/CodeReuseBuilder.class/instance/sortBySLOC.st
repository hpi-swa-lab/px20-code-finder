sorting
sortBySLOC
	"Sort the code snippets by the number of lines of code that contain source code (i.e., no comments) in ascending order."
	self sortBy:[:first :second | first source_lines_of_code < second source_lines_of_code].