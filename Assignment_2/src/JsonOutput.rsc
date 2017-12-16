module JsonOutput

import Common;
import Report;
import Type1_Duplication;

import IO;
import List;
import Map;
import String;
import Set;

int size(map[&T, &T] aMap) {
	return size([0 | a <- aMap]);
}

str serializeJsonArray(list[str] items) {
	if (items == []) {
		return "[]";
	}

	str outString = "[";
	for (int item <- [0..size(items)-1]) {
		outString += "<items[item]>,";
	}
	outString += "<last(items)>]";
	return outString;
}

void dumpFileDataToJson(loc outputFile, set[File] codeFiles, set[ClonedSection] clonedSectionsByFile) {
	appendToFile(outputFile, "\"files\" : ");
	
	int currentFile = 0;
	int totalFiles = size(codeFiles);
	appendToFile(outputFile, "[");
	for (File f <- codeFiles) {
		set[ClonedSection] clonedSections = {clonedSection | clonedSection <- clonedSectionsByFile, clonedSection.file == f.location};
		str clonesSectionsString = serializeJsonArray(["{\"start\" : \"<cs.section.lines.beginning>\","+
													   "\"end\" : \"<cs.section.lines.end>\"," + 
													   		"\"related-sections\" : <serializeJsonArray(["{\"file\" : \"<rcs.file>\","+
													   													  "\"start\" : \"<rcs.lines.beginning>\"," +
																										  "\"end\" : \"<rcs.lines.end>\"}" | rcs <- cs.relatedSections])>}"
																| cs <- clonedSections]);
		
		appendToFile(outputFile, "{\"location\" : \"<f.location>\"," + 
								  "\"size\" : \"<size(f.lines)>\","+
								  " \"clone-sections\" : <clonesSectionsString>}");
		currentFile += 1;
		if (currentFile < totalFiles) {
			appendToFile(outputFile, ",");
		}
	}
	appendToFile(outputFile, "]");
}

void dumpReportToJson(loc outputFile, CloneClasses classes, set[File] codeFiles) {
	appendToFile(outputFile, ",\"report\" : ");
	map[str, str] reportData = generateReport(classes, codeFiles);
	appendToFile(outputFile, serializeJsonArray(["{\"attribute\" : \"<k>\", \"value\" : \"<reportData[k]>\"}" | k <- reportData]));		
}

void dumpCloneInstancesToJson(loc outputFile, set[CodeFragment] cloneInstances) {
	appendToFile(outputFile, "\"clone-instances\" : ");
	str clonedFragments = serializeJsonArray(["{\"file\" : \"<clonedFragment.file.uri>\"," +
					  				 		  "\"start\" : \"<clonedFragment.lines.beginning>\"," +
				  							  "\"end\" : \"<clonedFragment.lines.end>\"}" | clonedFragment <- cloneInstances]);
    appendToFile(outputFile, clonedFragments);	
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

void dumpAllToJson(loc outputFile, CloneClasses classes, set[File] codeFiles, set[ClonedSection] clonedSectionsByFile) {
	writeFile(outputFile, "{\"clone-report\" : {");
	dumpFileDataToJson(outputFile, codeFiles, clonedSectionsByFile);
	dumpCloneClassesToJson(outputFile, classes, codeFiles);
	dumpReportToJson(outputFile, classes, codeFiles);
	appendToFile(outputFile, "}}");
}

////////////////////////////////////////
///// Development testing code
////////////////////////////////////////

void dumpAllToJsonTest() {
	//loc project = |project://smallsql0.21/src/smallsql/junit|;
	loc project = |project://smallsql0.21/src/smallsql|;
	//loc project = |project://smallTest/src|;
	//loc project = |project://hsqldb-2.3.1/hsqldb/src/org/hsqldb|;
	set[loc] fileLocations = getSourceFilesFromDirRecursively(project);
	set[File] files = {<f, getCleanLinesOfCodeFromFile(f)> | f <- fileLocations};
	set[CloneInstance] clones = findClones(files);
	CloneClasses cloneClasses = groupClonesByClass(clones);
	set[ClonedSection] clonedSectionsByFile = getClonedSections(files, clones);
	dumpAllToJson(|project://Assignment_2_Visualisation/se-visualisation/src/data.json|, cloneClasses, files, clonedSectionsByFile);
}
