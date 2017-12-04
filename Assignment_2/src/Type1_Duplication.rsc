module Type1_Duplication

import IO;

import Common;

alias File = tuple[loc location, list[str] lines];
alias CodeFragment = tuple[loc file, list[str] lines];
alias CloneClass = set[CodeFragment];

set[CloneClass] findClonesFromFile(File targetFile, list[File] files) {
	set[CloneClass] cloneClasses = {};
	// generate subsegments lines [1..6]
	list[list[str]] segments = [];
	// for each generated segment
		// go through all the files and find corresponding segments
	
	return cloneClasses;
}

////////////////////////////////////////
///// Test code
////////////////////////////////////////

void outputDuplication() {
	loc project = |project://smallTest/src|;
	list[loc] fileLocations = getSourceFilesFromDirRecursively(project);
	list[File] files = [<f, getCleanLinesOfCodeFromFile(f)> | f <- fileLocations];
	set[CloneClass] clones = {*findClonesFromFile(f, files - [f]) | f <- files};
//	TODO: Try with Type 1 clones, file by file, kill import statements
		//1. Foreach file -> map[loc, lines], clean up comments, trim whitespace, remove imports
		//	1. Foreach 6 line sequence of lines:
}