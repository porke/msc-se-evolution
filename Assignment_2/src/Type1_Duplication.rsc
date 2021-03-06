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
alias CloneClasses = map[CodeFragment, set[CodeFragment]];
alias ClonedSection = tuple[loc file, CodeFragment section, set[CodeFragment] relatedSections];

int minSegmentSize = 6;


list[str] mapSegmentToText(Segment seg, File file) {
	return [file.lines[line] | line <- [(seg.beginning)..(seg.end)]];
}

list[str] mapCodeFragmentToText(CodeFragment fragment, map[loc, File] files) {
	return mapSegmentToText(fragment.lines, files[fragment.file]);
}

int codeFragmentSize(CodeFragment fragment) {
	return fragment.lines.end - fragment.lines.beginning;
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
				// TODO: if two lines are duplicated, do a quick check line+minSegmentSize
				// if they are not equal, skip the whole segment
				clonedLines = clonedLines + 1;
				sourceLine = sourceLine + 1;
				if (sourceLine >= sourceFileSize) {
					break;
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

set[CloneInstance] findClones(set[File] files) {
	set[CloneInstance] clones = {};
	list[File] fileList = [f | f <- files, size(f.lines) >= minSegmentSize];
	int fileCount = size(fileList); 
	int totalComparisons = fileCount * (fileCount - 1) / 2;
	
	int filesProcessed = 0;
	datetime stopwatch = now();
	for (int sourceFileIdx <- [0..fileCount]) {
		for (int targetFileIdx <- [(sourceFileIdx+1)..fileCount]) {
			set[CloneInstance] foundClones = findClonesInFiles(fileList[sourceFileIdx], fileList[targetFileIdx]); 
			clones = clones + foundClones;
		
			filesProcessed = filesProcessed + 1;
			println("Processing <filesProcessed>/<totalComparisons> for <createDuration(stopwatch, now())>. " +
				    "Comparing: <fileList[sourceFileIdx].location.file> vs <fileList[targetFileIdx].location.file>");
		}
	}
	return clones;
}

set[ClonedSection] getClonedSections(set[File] files, set[CloneInstance] clones) {
	set[ClonedSection] sections = {};
	for (File file <- files) {
		set[CloneInstance] relatedSourceClones = {s | s <- clones, s.source.file == file.location};
		set[CloneInstance] relatedTargetClones = {s | s <- clones, s.target.file == file.location};
		set[CloneInstance] allRelatedClones = relatedSourceClones + invert(relatedTargetClones); 
		
		CloneClasses classesInFile = groupClonesByClass(allRelatedClones);		
		for (CodeFragment clonedSection <- classesInFile) {
			sections = sections + <file.location, clonedSection, classesInFile[clonedSection]>;			
		}
	}
	return sections;	
}

CloneClasses groupClonesByClass(set[CloneInstance] clones) {
	set[CloneInstance] cloneClasses = {};
	for (CloneInstance clone <- clones) {
		if (cloneClasses[clone.target] != {}) {
			cloneClasses[clone.target] = clone.source;
		}
		else {
			cloneClasses[clone.source] = clone.target;
		}
	}
	return Relation::index(cloneClasses);
}
