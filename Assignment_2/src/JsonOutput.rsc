module JsonOutput

import Common;
import Report;
import Type1_Duplication;

import IO;
import List;
import Map;
import String;

int size(map[&T, &T] aMap) {
	return size([0 | a <- aMap]);
}

void writeJsonArray(loc outputFile, list[str] items) {
	for (int item <- [0..size(items)-1]) {
		appendToFile(outputFile, "<items[item]>,");
	}
	appendToFile(outputFile, "<last(items)>");
}

void dumpFileDataToJson(loc outputFile, set[File] codeFiles) {
	appendToFile(outputFile, "\"files\" : [");	
	writeJsonArray(outputFile, ["{\"location\" : \"<f.location>\","+
								"\"size\" : \"<size(f.lines)>\"}" | f <- codeFiles]);	
	appendToFile(outputFile, "]");
}

void dumpReportToJson(loc outputFile, CloneClasses classes, set[File] codeFiles) {
	appendToFile(outputFile, ",\"report\" : [");
	map[str, str] reportData = generateReport(classes, codeFiles);
	writeJsonArray(outputFile, ["{\"attribute\" : \"<k>\", \"value\" : \"<reportData[k]>\"}" | k <- reportData]);	
	appendToFile(outputFile, "]");
}

void dumpCloneInstancesToJson(loc outputFile, set[CodeFragment] cloneInstances) {
	appendToFile(outputFile, "\"clone-instances\" : [");
	writeJsonArray(outputFile, ["{\"file\" : \"<clonedFragment.file.uri>\"," +
								  "\"start\" : \"<clonedFragment.lines.beginning>\"," +
								  "\"end\" : \"<clonedFragment.lines.end>\"}" | clonedFragment <- cloneInstances]);
	appendToFile(outputFile, "]");
}

void dumpCloneClassesToJson(loc outputFile, CloneClasses classes, set[File] files) {
	appendToFile(outputFile, ",\"clone-classes\" : [");
	
	int classesLeft = JsonOutput::size(classes);	
	for (CodeFragment clonedFragmentKey <- classes) {
		list[str] cloneLines = mapCodeFragmentToText(clonedFragmentKey, (f.location : f | f <- files));
		str cloneString = intercalate("\\r\\n", cloneLines);
		appendToFile(outputFile, "{\"clone-text\" : \"<escape(cloneString, ("\"" : "\\\""))>\", ");
		dumpCloneInstancesToJson(outputFile, clonedFragmentKey + classes[clonedFragmentKey]);	
		
		classesLeft -= 1;
		if (classesLeft > 0) {		
			appendToFile(outputFile, "},");
		}
		else {
			appendToFile(outputFile, "}");
		}
	}
	appendToFile(outputFile, "]");
}

void dumpAllToJson(loc outputFile, CloneClasses classes, set[File] codeFiles) {
	writeFile(outputFile, "{\"clone-report\" : {");
	dumpFileDataToJson(outputFile, codeFiles);
	dumpCloneClassesToJson(outputFile, classes, codeFiles);
	dumpReportToJson(outputFile, classes, codeFiles);
	appendToFile(outputFile, "}}");
}

////////////////////////////////////////
///// Development testing code
////////////////////////////////////////

void dumpAllToJsonTest() {
	//loc project = |project://smallsql0.21/src/smallsql/junit|;
	//loc project = |project://smallTest/src|;
	loc project = |project://hsqldb-2.3.1/hsqldb/src/org/hsqldb|;
	set[loc] fileLocations = getSourceFilesFromDirRecursively(project);
	set[File] files = {<f, getCleanLinesOfCodeFromFile(f)> | f <- fileLocations};
	CloneClasses clones = groupClonesByClass(findClones(files));
	dumpAllToJson(|project://Assignment_2_Visualisation/se-visualisation/src/data.json|, clones, files);
}
