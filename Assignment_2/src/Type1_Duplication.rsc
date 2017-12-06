module Type1_Duplication

import IO;
import List;
import Relation;
import Set;
import DateTime;
import util::ValueUI;

import Common;

alias File = tuple[loc location, list[str] lines];
alias FileComparison = tuple[loc from, loc to];
alias Segment = tuple[int beginning, int end];
alias CodeFragment = tuple[loc file, Segment lines];
alias CloneInstance = tuple[CodeFragment source, CodeFragment target];
alias CloneClasses = set[CloneInstance];

int minSegmentSize = 6;


list[str] mapSegmentToText(Segment seg, File file) {
	return [file.lines[line] | line <- [(seg.beginning)..(seg.end)]];
}

list[str] mapCodeFragmentToText(CodeFragment fragment, map[loc, File] files) {
	return mapSegmentToText(fragment.lines, files[fragment.file]);
}

CloneInstance createCloneInstance(File source, File target, int clonedLines, int sourceLineEnd, int targetLineEnd) {
	return <<source.location, <sourceLineEnd - clonedLines, sourceLineEnd>>, <target.location, <targetLineEnd - clonedLines, targetLineEnd>>>;
}

set[CloneInstance] findClonesInFiles(File sourceFile, File targetFile) {	
	set[CloneInstance] cloneInstances = {};
	int sourceLine = 0;	
	int sourceFileSize = size(sourceFile.lines);
	int targetFileSize = size(targetFile.lines);
	while (sourceLine < sourceFileSize) {
		int clonedLines = 0;
		int targetLine = 0;
		while (targetLine < targetFileSize) {
			if (sourceFile.lines[sourceLine] == targetFile.lines[targetLine]) {			
				// Quick filter out segments which have a different ending 
				if (clonedLines == 1 &&
					(sourceLine + minSegmentSize >= sourceFileSize
					|| targetLine + minSegmentSize >= targetFileSize
					|| sourceFile.lines[sourceLine + minSegmentSize] != targetFile.lines[targetLine + minSegmentSize])) {
					clonedLines = 0;
					targetLine = targetLine + minSegmentSize - 1;
				}
				else {
					clonedLines = clonedLines + 1;
					sourceLine = sourceLine + 1;
					if (sourceLine >= sourceFileSize) {
						break;
					}
				}				
			}
			else {
				if (clonedLines >= minSegmentSize) {
					cloneInstances = cloneInstances + createCloneInstance(sourceFile, targetFile, clonedLines, sourceLine, targetLine); 
				}
				clonedLines = 0;
			}
			targetLine = targetLine + 1;
		}
		if (clonedLines >= minSegmentSize) {
			cloneInstances = cloneInstances + createCloneInstance(sourceFile, targetFile, clonedLines, sourceLine, targetLine);
		}
		sourceLine = sourceLine + 1;		
	}
	return cloneInstances;
}

set[FileComparison] genComparisons(set[loc] files) {
	datetime stopwatch = now();
	set[FileComparison] noIdentComparisons = files*files - ident(files);
	// Prune symmetric comparisons, if <A, B> is in finalRelation, we don't want <B, A> to be there
	set[FileComparison] finalRelation = {};	
	for (FileComparison element <- noIdentComparisons) {
		if (element.from notin finalRelation[element.to]) {
			finalRelation[element.from] = element.to;		
		}
	}
	println("Comparisons computed in: <createDuration(stopwatch, now())>");
	return finalRelation;
}

set[CloneInstance] findClones(set[File] files) {
	set[CloneInstance] cloneClasses = {};
	set[FileComparison] comparisons = genComparisons(domain(files));
	int filesProcessed = 0;	
	map[loc, File] fileLocations = (f.location : f | f <- files);
	datetime stopwatch = now();
	for (FileComparison currFiles <- comparisons) {
		set[CloneInstance] foundClones = findClonesInFiles(fileLocations[currFiles.from], fileLocations[currFiles.to]); 
		cloneClasses = cloneClasses + foundClones;
		
		filesProcessed = filesProcessed + 1;		
		println("Processing <filesProcessed>/<size(comparisons)> for <createDuration(stopwatch, now())>. Comparing: <currFiles.from.file> vs <currFiles.to.file>");
		
	}
	return cloneClasses;
}

int totalCloneCount(CloneClasses clones) {
	return size(carrier(clones));
}

int numCloneClasses(CloneClasses clones) {
	return size(domain(clones));
}

int biggestCloneClass(CloneClasses clones) {
	return -1;
}

int biggestClone(CloneClasses clones) {
	return -1;
}

////////////////////////////////////////
///// Test code
////////////////////////////////////////

void findClonesTest() {
	loc project = |project://smallsql0.21/src/smallsql/junit|;
	set[loc] fileLocations = getSourceFilesFromDirRecursively(project);
	set[File] files = {<f, getCleanLinesOfCodeFromFile(f)> | f <- fileLocations};
	
	map[loc, File] fileMappings = (f.location : f | f <- files);
	CloneClasses clones = findClones(files);
	iprintln([mapCodeFragmentToText(c.source, fileMappings) | c <- clones]);
	text(clones);
	println("===== Some stats =====");
	println("Total clone count: <totalCloneCount(clones)>");
	println("Clone class count: <numCloneClasses(clones)>");
	println("Biggest clone: <biggestClone(clones)>");
	println("Biggest clone class: <biggestCloneClass(clones)>");
	println("Example clone: <"?">");
}

void findClonesFromFileTest() {
	loc project = |project://smallsql0.21/src/smallsql/junit|;
	set[loc] fileLocations = getSourceFilesFromDirRecursively(project);
	iprintln(genComparisons(fileLocations));
}

void findClonesInFilesTest() {
	loc project = |project://smallTest/src|;
	set[loc] fileLocations = getSourceFilesFromDirRecursively(project);
	list[File] files = [<f, getCleanLinesOfCodeFromFile(f)> | f <- fileLocations];
	iprintln(findClonesInFiles(files[0], files[1]));
}

void mapSegmentToTextTest() {
	loc project = |project://smallTest/src|;
	set[loc] fileLocations = getSourceFilesFromDirRecursively(project);
	list[File] files = [<f, getCleanLinesOfCodeFromFile(f)> | f <- fileLocations];
	iprintln(mapSegmentToText(<0, 6>, files[0]));
}

