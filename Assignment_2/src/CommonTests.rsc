module CommonTests

import IO;

import Common;

test bool pruneImportPackageStatements_removesImportAndPackageStatements() {
	list[str] input = ["package smallsql.junit;", "import java.sql.*;", "public class BenchTest", "{", "static byte[] byteArray = {23, 34, 67 };"]; 
	list[str] sanitizedLines = pruneImportPackageStatements(input);
	return sanitizedLines == ["public class BenchTest", "{", "static byte[] byteArray = {23, 34, 67 };"];
}

test bool pruneWhitespaceAndSingleLineComments_removesWhitespaceLines() {
	list[str] input = ["public class BenchTest", "{", "", "", "\tstatic byte[] byteArray = {23, 34, 67 };"]; 
	list[str] sanitizedLines = pruneWhitespaceAndSingleLineComments(input);
	return sanitizedLines == ["public class BenchTest", "{", "static byte[] byteArray = {23, 34, 67 };"];	
}

test bool pruneWhitespaceAndSingleLineComments_removesSlashComments() {
	list[str] input = ["public class BenchTest", "{", "// The array holds input bytes", "static byte[] byteArray = {23, 34, 67 };"]; 
	list[str] sanitizedLines = pruneWhitespaceAndSingleLineComments(input);
	return sanitizedLines == ["public class BenchTest", "{", "static byte[] byteArray = {23, 34, 67 };"];
}

test bool pruneWhitespaceAndSingleLineComments_removesMultilineStyleComments() {
	list[str] input = ["public class BenchTest", "{", "/* The array holds input bytes */", "static byte[] byteArray = {23, 34, 67 };"]; 
	list[str] sanitizedLines = pruneWhitespaceAndSingleLineComments(input);
	return sanitizedLines == ["public class BenchTest", "{", "static byte[] byteArray = {23, 34, 67 };"];	
}

test bool pruneMultilineComments_removesCommentsSpanningMultipleLinesStartingWithWhitespaceAndEndingWithWhitespace() {
	list[str] input = ["public class BenchTest", "{", "    /*", "The array holds input bytes", "*/    \t", "static byte[] byteArray = {23, 34, 67 };"]; 
	list[str] sanitizedLines = pruneMultilineComments(input);
	iprintln(sanitizedLines);
	return sanitizedLines == ["public class BenchTest", "{", "static byte[] byteArray = {23, 34, 67 };"];
}

// TODO: For this case it dies, fix it! 
//test bool pruneMultilineComments_removesCommentsSpanningMultipleLinesStartingWithCodeAndEndingWithCode() {
//	list[str] input = ["public class BenchTest", "{", "private int a; /*", "The array holds input bytes", "*/private int b;", "static byte[] byteArray = {23, 34, 67 };"]; 
//	list[str] sanitizedLines = pruneMultilineComments(input);
//	iprintln(sanitizedLines);
//	return sanitizedLines == ["public class BenchTest", "{", "private int a; /*", "*/private int b;", "static byte[] byteArray = {23, 34, 67 };"];
//}