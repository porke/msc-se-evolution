module Type1_DuplicationTests

import IO;
import Set;

import Type1_Duplication;
import Common;

test bool justTestIt() {
	return true;
}

// test cases:
// genComparisons
//	- empty set
//  - one symmetric pair getting removed
//

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
	set[CloneInstance] clones = findClonesInFiles(file1, file2);
	return size(clones) == 2;
}

test bool findClonesInFile_duplicationShorterThanTwoMinSegmentSize() {
	loc defaultLocation = |unknown:///|;
	File file1 = <defaultLocation, ["class D {", "public void a() {", "int a = 0;", "a++;", "a--", "int b = a + 4;", "}", "}"]>;
	File file2 = <defaultLocation, ["class E {", "public void a() {", "int a = 0;", "a++;", "int b = 123;", "b++;" , "}", "}"]>;
	set[CloneInstance] clones = findClonesInFiles(file1, file2);
	return size(clones) == 0;
}

// groupClonesByCLass
//  - two clone instances of the same class, make one class of them
//  - two clone instances of a different class, make two classes of them
