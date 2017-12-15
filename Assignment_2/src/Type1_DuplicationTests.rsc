module Type1_DuplicationTests

import IO;
import Set;
import Relation;

import Type1_Duplication;
import Common;


test bool findClonesInFiles_filesWithOne7LineCloneInstance() {
	loc defaultLocation = |unknown:///|;
	File file1 = <defaultLocation, ["class D {", "public void a() {", "int a = 0;", "a++;", "a--", "int b = a + 4;", "}", "}"]>;
	File file2 = <defaultLocation, ["class E {", "public void a() {", "int a = 0;", "a++;", "a--", "int b = a + 4;", "}", "}"]>;
	set[CloneInstance] clones = findClonesInFiles(file1, file2);
	return size(clones) == 1;
}

test bool findClonesInFiles_filesWithNoDuplication() {
	loc defaultLocation = |unknown:///|;
	File file1 = <defaultLocation, ["class D {", "public void a() {", "int a = 0;", "a++;", "a--", "int b = a + 4;", "}", "}"]>;
	File file2 = <defaultLocation, ["class E {", "public bool c() {", "int a = 123;", "a += 55;", "a -= 12", "int b = a + 77;", "return false;}", "}"]>;
	set[CloneInstance] clones = findClonesInFiles(file1, file2);
	return size(clones) == 0;
}

test bool findClonesInFiles_filesWithTwoDuplicatedSegments() {
	loc defaultLocation = |unknown:///|;
	File file1 = <defaultLocation, ["class D {", "public void a() {", "int a = 0;", "a++;", "a--", "int b = a + 7;", "}", "private int m_b;",
												 "private bool m_flag;", "public bool c() {", "float f = 34;", "f /= 2.0f", "float g = Math.sin(f); return g \> 0.5f", "}"]>;
	File file2 = <defaultLocation, ["class E {", "public void a() {", "int a = 0;", "a++;", "a--", "int b = a + 7;", "}", "}",
												 "private bool m_flag;", "public bool c() {", "float f = 34;", "f /= 2.0f", "float g = Math.sin(f); return g \> 0.5f", "}"]>;
	File file3 = <defaultLocation, ["class D {", "public void a() {", "int a = 0;", "a++;", "a--", "int b = a + 7;", "}", "private int m_b;",
												 "private bool m_flag;", "public bool c() {", "float f = 34;", "f /= 2.0f", "float g = Math.sin(f); return g \> 0.5f", "}"]>;
	File file4 = <defaultLocation, ["class E {", "private bool m_flag;", "public bool c() {", "float f = 34;", "f /= 2.0f", "float g = Math.sin(f); return g \> 0.5f", "}" ,
												 "public void a() {", "int a = 0;", "a++;", "a--", "int b = a + 7;", "}", "}"]>;
	set[CloneInstance] clones = findClonesInFiles(file1, file2);
	set[CloneInstance] clones2 = findClonesInFiles(file3, file4);
	set[CloneInstance] clones3 = findClonesInFiles(file1, file1);
	return size(clones) == 2 && size(clones2) == 2 && size(clones3) == 1;
}

test bool findClonesInFile_duplicationShorterThanTwoMinSegmentSize() {
	loc defaultLocation = |unknown:///|;
	File file1 = <defaultLocation, ["class D {", "public void a() {", "int a = 0;", "a++;", "a--", "int b = a + 4;", "}", "}"]>;
	File file2 = <defaultLocation, ["class E {", "public void a() {", "int a = 0;", "a++;", "int b = 123;", "b++;" , "}", "}"]>;
	set[CloneInstance] clones = findClonesInFiles(file1, file2);
	return size(clones) == 0;
}

test bool groupClonesByClass_twoCloneInstancesOfTheSameClass_madeIntoOneClass() {
	loc file1 = |unknown:///a.java|;
	loc file2 = |unknown:///b.java|;
	CodeFragment frag1 = <file1, <1, 17>>;
	CodeFragment frag2 = <file2, <2, 18>>;
	CodeFragment frag3 = <file1, <1, 17>>;
	CodeFragment frag4 = <file2, <7, 32>>;
	CloneInstance clone1 = <frag1, frag2>;
	CloneInstance clone2 = <frag3, frag4>;
	
	CloneClasses classes = groupClonesByClass({clone1, clone2});
	set[CodeFragment] cloneExamples = {c | c <- classes};
	return size(cloneExamples) == 1 && size(classes[getOneFrom(cloneExamples)]) == 2;
}
