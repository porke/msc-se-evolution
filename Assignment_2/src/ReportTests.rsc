module ReportTests

import IO;

import Report;
import Type1_Duplication;


set[CloneInstance] createThreeCloneInstancesInOneClass() {
	loc file1 = |unknown:///a.java|;
	loc file2 = |unknown:///b.java|;
	CodeFragment frag1 = <file1, <1, 17>>;
	CodeFragment frag2 = <file2, <2, 18>>;
	CodeFragment frag3 = <file1, <1, 17>>;
	CodeFragment frag4 = <file2, <7, 23>>;
	CloneInstance clone1 = <frag1, frag2>;
	CloneInstance clone2 = <frag3, frag4>;

	return {clone1, clone2};
}

test bool totalCloneCount_test() {
	return totalCloneCount(groupClonesByClass(createThreeCloneInstancesInOneClass())) == 3;	
}

test bool numCloneClasses_test() {
	return numCloneClasses(groupClonesByClass(createThreeCloneInstancesInOneClass())) == 1;
}

test bool largestCloneClass_test() {
	iprintln(largestCloneClass(groupClonesByClass(createThreeCloneInstancesInOneClass())));
	return largestCloneClass(groupClonesByClass(createThreeCloneInstancesInOneClass())) == 3;
}

test bool largestClone_test() {
	int expectedSize = 16;
	return largestClone(groupClonesByClass(createThreeCloneInstancesInOneClass())) == 16;
}

test bool totalLines_test() {
	int expectedLines = 12;
	File file1 = <|unknown:///a.java|, ["" | a <- [1..7]]>;
	File file2 = <|unknown:///b.java|, ["" | a <- [1..7]]>;
	set[File] files = {file1, file2};
	
	return totalLines(files) == expectedLines;
}

test bool totalDuplicatedLines_test() {
	int expectedLines = 48;

	set[CloneInstance] cloneInstances = createThreeCloneInstancesInOneClass();
	CloneClasses classes = groupClonesByClass(cloneInstances);
	return totalDuplicatedLines(classes) == expectedLines;
}
