sorting
sortByScore
	"Sort the code snippets by the number of upvotes that they received (i.e., score). It sums both the number of upvotes for the question and for the answer."
	self sortBy: [:first :second | (first question_score + first answer_score) > (second question_score + second answer_score)].