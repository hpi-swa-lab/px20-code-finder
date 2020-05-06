sorting
sortByIndex
	"Sort the code snippets by the initial order, which was determined by the point in time when they became available."
	self sortBy:[:first :second | first index < second index].