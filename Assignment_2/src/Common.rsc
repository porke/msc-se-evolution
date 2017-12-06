module Common

import util::ValueUI;

import IO;
import List;
import String;

alias Metric = tuple[str name, num val];
alias CodeProperty = tuple[str name, list[Metric] metrics];

list[str] pruneImportStatements(list[str] lines) {	
	return [line | line <- lines, /^import*$/ !:= line, /^package.*$/ !:= line];
}

// TODO:  account for this case:
// codecodecode /* comment
// * comment some mode
// comment even more
// end the comment */
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
				append trim(line);
			}
		}
	}
}

list[str] getCleanLinesOfCodeFromFile(loc file) {
	list[str] totalLines = readFileLines(file);
	list[str] noImports = pruneImportStatements(totalLines);
	list[str] lines = pruneWhitespaceAndSingleLineComments(noImports);
	return pruneMultilineComments(lines);
}

list[str] pruneWhitespaceAndSingleLineComments(list[str] lines) {
	return [trim(line) | line <- lines,
			/^[\s]*$/ !:= line,					// Whitespace lines
			/^[\s]*[\/]{2,}.*$/ !:= line,		// Single line comments
			/^[\s]*(\/\*).*(\*\/)[\s]*$/ !:= line ]; // Single line comments with *
}

set[loc] getSourceFilesFromDirRecursively(loc directory) {
	set[loc] sourceFiles = {directory + s | s <- listEntries(directory), isFile(directory + s)};
	set[loc] subDirectories = {directory + s | s <- listEntries(directory), isDirectory(directory + s)};	
	return sourceFiles + {*getSourceFilesFromDirRecursively(d) | d <- subDirectories};
}

int computeTotalLinesOfCode(loc projectLocation) {
	list[int] linesPerFile = [size(getCleanLinesOfCodeFromFile(s)) | s <- getSourceFilesFromDirRecursively(projectLocation)];		
	return sum(linesPerFile);
}
