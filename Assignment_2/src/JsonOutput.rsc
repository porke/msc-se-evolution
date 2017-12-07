module JsonOutput

import Common;
import Report;
import Type1_Duplication;

import IO;
import List;

void dumpFileDataToJson(loc outputFile, set[File] codeFiles) {
	appendToFile(outputFile, "\"files\" : [");
	for (File f <- codeFiles) {
		appendToFile(outputFile, "{\"<f.location>\" : \"<size(f.lines)>\"}, ");
	}
	appendToFile(outputFile, "{}]");
}

void dumpReportToJson(loc outputFile, CloneClasses classes) {
	appendToFile(outputFile, ",\"report\" : [");
	map[str, str] reportData = generateReport(classes);
	for (k <- reportData) {
		appendToFile(outputFile, "{\"<k>\" : \"<reportData[k]>\"},");
	}
	
	appendToFile(outputFile, "{}]");
}

void dumpCloneClassesToJson(loc outputFile, CloneClasses classes) {
	// TODO
}

void dumpAllToJson(loc outputFile, CloneClasses classes, set[File] codeFiles) {
	writeFile(outputFile, "{\"clone-report\" : {");
	dumpFileDataToJson(outputFile, codeFiles);
	dumpCloneClassesToJson(outputFile, classes);
	dumpReportToJson(outputFile, classes);
	appendToFile(outputFile, "}}");
}

////////////////////////////////////////
///// Test code
////////////////////////////////////////

void dumpAllToJsonTest() {
	loc project = |project://smallTest/src|;
	set[loc] fileLocations = getSourceFilesFromDirRecursively(project);
	set[File] files = {<f, getCleanLinesOfCodeFromFile(f)> | f <- fileLocations};
	dumpAllToJson(|project://Assignment_2_Visualisation/test.json|, (), files);
}
