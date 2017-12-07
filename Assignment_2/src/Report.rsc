module Report

import Common;
import Type1_Duplication;

import Set;
import Map;
import List;

import util::ValueUI;
import IO;


set[CodeFragment] allCloneInstances(CloneClasses clones) {
	return domain(clones) + {*e | e <- range(clones)};
}

int totalCloneCount(CloneClasses clones) {
	return size(allCloneInstances(clones));
}

int numCloneClasses(CloneClasses clones) {
	return size(clones);
}

int largestCloneClass(CloneClasses clones) {	
	return max({size(c) | c <- range(clones)});
}

int largestClone(CloneClasses clones) {
	return max({codeFragmentSize(e) | e <- allCloneInstances(clones)});
}

int totalLines(set[File] codeFiles) {
	return sum([size(c.lines) | c <- codeFiles]);
}

int totalDuplicatedLines(CloneClasses clones) {
	set[CodeFragment] allClones = allCloneInstances(clones);
	return sum([codeFragmentSize(codeFragment) | codeFragment <- allClones]);
}

map[str, str] generateReport(CloneClasses clones, set[File] codeFiles) {
	return ("Total clone count" : "<totalCloneCount(clones)>",
			"Clone class count" : "<numCloneClasses(clones)>",
			"Largest clone class" : "<largestCloneClass(clones)>",
			"Largest clone" : "<largestClone(clones)>",
			"Total lines" : "<totalLines(codeFiles)>",
			"Total duplicated lines" : "<totalDuplicatedLines(clones)>");
}


////////////////////////////////////////
///// Test code
////////////////////////////////////////

void generateReportTest() {
	loc project = |project://smallsql0.21/src/smallsql/junit|;
	set[loc] fileLocations = getSourceFilesFromDirRecursively(project);
	set[File] files = {<f, getCleanLinesOfCodeFromFile(f)> | f <- fileLocations};
	
	map[loc, File] fileMappings = (f.location : f | f <- files);
	CloneClasses clones = groupClonesByClass(findClones(files));
	iprintln(generateReport(clones, files));
}
