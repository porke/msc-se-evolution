module Common

import util::ValueUI;

import IO;
import List;

alias Metric = tuple[str name, num val];
alias CodeProperty = tuple[str name, list[Metric] metrics];

list[str] pruneMultilineComments(list[str] lines) {
	list[str] outList = [];
	bool isComment = false;
	return for (i <- [0..(size(lines))]){
		str line = lines[i];
		if (isComment) {
			bool isCurrLineCommentEnd = (/^.*(\*\/)[\s]*$/ := line);
			isComment = !isCurrLineCommentEnd;
		}
		else {
			isComment = (/^[\s]*(\/\*).*$/ := line);
			if (!isComment) {
				append line;
			}
		}
	}
}

list[str] pruneWhitespaceAndSingleLineComments(list[str] lines) {
	return [line | line <- lines,
			/^[\s]*$/ !:= line,					// Whitespace lines
			/^[\s]*[\/]{2,}.*$/ !:= line,		// Single line comments
			/^[\s]*(\/\*).*(\*\/)[\s]*$/ !:= line ]; // Single line comments with *
}

int getLinesOfCodeFromLocation(loc file) {
	list[str] totalLines = readFileLines(file);
	list[str] lines = pruneWhitespaceAndSingleLineComments(totalLines);
	list[str] physicalCodeLines = pruneMultilineComments(lines); 
	return size(physicalCodeLines);
}
