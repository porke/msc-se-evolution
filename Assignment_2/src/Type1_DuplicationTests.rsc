module Type1_DuplicationTests

import IO;

public test bool justTestIt() {
	println("I am failing!");
	return false;
}

// test cases:
// genComparisons
//	- empty set
//  - one symmetric pair getting removed
//
// findClonesInFiles
//  - two identical files 
//  - two files with no duplication
//  - two files with two different duplicated segments
//  - two files with duplications shorter than 6 lines
//
// groupClonesByCLass
//  - two clone instances of the same class, make one class of them
//  - two clone instances of a different class, make two classes of them
