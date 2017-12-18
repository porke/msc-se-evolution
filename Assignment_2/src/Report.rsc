module Report

import Common;
import Type1_Duplication;

import Set;
import Map;
import List;
import util::Math;


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
	// The one additional clone includes the fragment that is being copied
	// in addition to all the places where it has been copied to
	return max({size(c) | c <- range(clones)}) + 1;
}

int largestClone(CloneClasses clones) {
	return max({Type1_Duplication::codeFragmentSize(e) | e <- allCloneInstances(clones)});
}

int totalLines(set[File] codeFiles) {
	return sum([size(c.lines) | c <- codeFiles]);
}

int totalDuplicatedLines(CloneClasses clones) {
	set[CodeFragment] allClones = allCloneInstances(clones);
	return sum([Type1_Duplication::codeFragmentSize(codeFragment) | codeFragment <- allClones]);
}

map[str, str] generateReport(CloneClasses clones, set[File] codeFiles) {
	int totalLineCount = totalLines(codeFiles);
	int totalDuplicatedLineCount = totalDuplicatedLines(clones);
	num duplicationPercentage = round(totalDuplicatedLineCount / toReal(totalLineCount) * 100, 0.1);

	return ("Total clone count" : "<totalCloneCount(clones)>",
			"Clone class count" : "<numCloneClasses(clones)>",
			"Largest clone class" : "<largestCloneClass(clones)>",
			"Largest clone" : "<largestClone(clones)>",
			"Total lines" : "<totalLineCount>",
			"Total duplicated lines" : "<totalDuplicatedLineCount>",
			"Duplication percentage" : "<duplicationPercentage>");
}

