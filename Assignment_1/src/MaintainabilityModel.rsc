module MaintainabilityModel

import util::Math;
import List;
import Set;
import Relation;
import util::ValueUI;
import IO;

import Common;
import Duplication;
import Volume;
import UnitComplexity;
import UnitSize;

alias SystemProperty = tuple[str name, list[CodePropertyEvaluation] properties];
alias CodePropertyEvaluation = tuple[CodeProperty property, Quality (CodeProperty) evaluationFunc];
alias Quality = int;

Quality MinQuality = 1;
Quality MaxQuality = 5;

int getThresholdRank(num valueRanked, list[num] thresholds) {
	return size([x | x <- thresholds, valueRanked <= x]) + 1;
}

Quality getVolumeQuality(CodeProperty volume) {
	list[int] thresholds = [66, 246, 665, 1310];
	num linesOfCodeInThousands = volume.metrics[0].val / 1000;	
	return getThresholdRank(linesOfCodeInThousands, thresholds);
}

Quality getUnitSizeQuality(CodeProperty unitSize) {
	// Classification derived from Better Code Hub because it is not in the paper
	list[int] lineThresholds = [15, 30, 60];	
	int totalLinesOfCode = sum([toInt(x) | x <- unitSize.metrics.val]);	
	
	// Mapping the line counts to risk categories where
	// 1 - low risk, 4 - very high risk
	int minRank = 1;
	int maxRank = 4;
	list[int] thresholdRanks = [minRank..(maxRank+1)];
	list[tuple[int rank, int lines]] lineCountByThreshold = [<1 + maxRank - getThresholdRank(m.val, lineThresholds), toInt(m.val)> | m <- unitSize.metrics];	
	rel[int, num] aggregatedLineCounts = {<threshold, sum([x.lines | x <- lineCountByThreshold, x.rank == threshold])> | threshold <- thresholdRanks};	
	// Map the aggregated line counts to percentages of code in each categories	
	list[real] sizeCategories = [toReal(sum(aggregatedLineCounts[rank])) / toReal(totalLinesOfCode) | rank <- thresholdRanks];
	
	// Thresholds for low, medium, high and very high risk code 
	list[list[real]] relativeSizeThresholds = [[1.0, 1.0, 1.0, 1.0], [0.25, 0.3, 0.4, 0.5], [0.0, 0.01, 0.1, 0.15], [0.0, 0.0, 0.0, 0.05]];
	list[int] qualitiesPerSizeCategory = [getThresholdRank(sizeCategories[x - 1], relativeSizeThresholds[x - 1]) | x <- thresholdRanks];    
	return min(qualitiesPerSizeCategory);
}

Quality getUnitComplexityQuality(CodeProperty unitComplexity) {
	// risk wrt CC: low, moderate, high, very high
	list[int] riskThresholds = [11, 21, 51];
	int totalLinesOfCode = sum([toInt(x) | x <- unitComplexity.metrics.val]); 	// Test data
	
	// Risk thresholds wrt quality ratings
	// 1 - low risk, 4 - very high risk
	int minRank = 1;
	int maxRank = 4;
	list[int] thresholdRanks = [minRank..(maxRank+1)];
	list[tuple[int rank, int complexity]] complexityByThreshold = [<1 + maxRank - getThresholdRank(m.val, riskThresholds), toInt(m.val)> | m <- unitComplexity.metrics];
	rel[int, num] aggregatedComplexities = {<threshold, sum([x.complexity | x <- complexityByThreshold, x.rank == threshold])> | threshold <- thresholdRanks};	
	list[real] riskCategories = [toReal(sum(aggregatedComplexities[rank])) / toReal(totalLinesOfCode) | rank <- thresholdRanks];
	list[list[real]] relativeRiskThresholds = [[1.0, 1.0, 1.0, 1.0], [0.25, 0.3, 0.4, 0.5], [0.0, 0.01, 0.1, 0.15], [0.0, 0.0, 0.0, 0.05]];
	list[int] qualitiesPerRiskCategory = [getThresholdRank(riskCategories[x - 1], relativeRiskThresholds[x - 1]) | x <- thresholdRanks];	
	return min(qualitiesPerRiskCategory);
}

Quality getDuplicationQuality(CodeProperty duplication) {
	list[real] thresholds = [0.03, 0.05, 0.1, 0.2];
	int totalLinesOfCode = 12345; 	// Test data
	real duplicationPercentage = duplication.metrics[0].val / totalLinesOfCode;
	return getThresholdRank(duplicationPercentage, thresholds);
}

list[CodePropertyEvaluation] computeCodeProperties(loc project) {
	return [<computeVolume(project), getVolumeQuality>,
			<computeUnitSize(project), getUnitSizeQuality>,
			<computeUnitComplexity(project), getUnitComplexityQuality>,
			<computeDuplication(project), getDuplicationQuality>];
}

list[SystemProperty] createSystemProperties(list[CodePropertyEvaluation] props) {
	SystemProperty analysability = <"Analysability", [pe | pe <- props, pe.property.name == "Volume" || pe.property.name == "Duplication" || pe.property.name == "UnitSize"]>;
	SystemProperty testability = <"Testability", [pe | pe <- props, pe.property.name == "UnitComplexity" || pe.property.name == "UnitSize"]>;
	SystemProperty changeability = <"Changeability", [pe | pe <- props, pe.property.name == "Duplication" || pe.property.name == "UnitComplexity"]>;
	return [analysability, testability, changeability];
}

Quality getSystemPropertyQuality(SystemProperty prop) {
	return sum([0] + [pe.evaluationFunc(pe.property) | pe <- prop.properties]) / size(prop.properties);
}

void computeModel(loc project) {
	list[CodePropertyEvaluation] codeProperties = computeCodeProperties(project);
	list[SystemProperty] systemProperties = createSystemProperties(codeProperties);
	iprintln([<sp.name, getSystemPropertyQuality(sp), [<cp.property.name, cp.evaluationFunc(cp.property)> | cp <- sp.properties]> | sp <- systemProperties]);
	// TODO: visualize the model?
}

//////////////////////////////////////////////////
// Test code
//////////////////////////////////////////////////

void computeModel() {
	loc project = |project://smallsql0.21/|;
	computeModel(project);
}

void computeUnitSizeQuality() {
	loc project = |project://smallsql0.21/|;
	CodeProperty property = computeUnitSize(project); 
	iprintln(getUnitSizeQuality(property));
}

void computeVolumeQuality() {
	loc project = |project://smallsql0.21/|;
	CodeProperty property = computeVolume(project); 
	iprintln(getVolumeQuality(property));
}

void computeUnitComplexityQuality() {
	loc project = |project://smallsql0.21/|;
	CodeProperty property = computeUnitComplexity(project); 
	iprintln(getUnitComplexityQuality(property));
}