module MaintainabilityModel

import util::Math;
import List;
import IO;
import DateTime;

import Common;
import Duplication;
import Volume;
import UnitComplexity;
import UnitSize;

alias SystemProperty = tuple[str name, list[CodePropertyEvaluation] properties];
alias CodePropertyEvaluation = tuple[CodeProperty property, Quality (CodeProperty, list[int]) evaluationFunc, list[int] thresholds];
alias MaintainabilityModel = list[SystemProperty];
alias Quality = int;

int getThresholdRank(num valueRanked, list[num] thresholds) {
	return size([x | x <- thresholds, valueRanked < x]) + 1;
}

map[int, num] getAggregatedValueCounts(list[num] metricValues,
									   list[int] thresholdValues) {
	int minRank = 1;
	int maxRank = size(thresholdValues) + 1;
	list[int] thresholdRanks = [minRank..(maxRank+1)];
	
	list[tuple[int rank, int lines]] valueByThreshold = [<1 + maxRank - getThresholdRank(m, thresholdValues), toInt(m)> | m <- metricValues];	
	return (threshold : sum([x.lines | x <- valueByThreshold, x.rank == threshold]) | threshold <- thresholdRanks);
}

list[real] getValueCategories(map[int, num] aggregatedValueCounts, int totalValue, list[int] thresholdRanks) {
	return [toReal(aggregatedValueCounts[rank]) / toReal(totalValue) | rank <- thresholdRanks];
}

Quality getQualityForThresholds(list[num] metricValues,
							   	list[int] thresholdValues,
							   	list[list[real]] categoryThresholds,
								int totalValue) {
	int minRank = 1;
	int maxRank = size(thresholdValues) + 1;
	list[int] thresholdRanks = [minRank..(maxRank+1)];
								
	// Map the aggregated values to percentages of code in each categories
	map[int, num] aggregatedValueCounts = getAggregatedValueCounts(metricValues, thresholdValues);	
	list[real] valueCategories = getValueCategories(aggregatedValueCounts, totalValue, thresholdRanks);	
	// Thresholds for low, medium, high and very high risk code
	list[int] qualitiesPerSizeCategory = [getThresholdRank(valueCategories[x - 1], categoryThresholds[x - 1]) | x <- thresholdRanks];    
	return min(qualitiesPerSizeCategory);
}

Quality getVolumeQuality(CodeProperty volume, list[int] thresholds) {	
	num linesOfCodeInThousands = volume.metrics[0].val / 1000;	
	return getThresholdRank(linesOfCodeInThousands, thresholds);
}

Quality getUnitSizeQuality(CodeProperty unitSize, list[int] lineThresholds) {
	// Classification derived from Better Code Hub because it is not in the paper
	int totalLinesOfCode = sum([toInt(x) | x <- unitSize.metrics.val]);
	list[list[real]] relativeSizeThresholds = [[1.0, 1.0, 1.0, 1.0], [0.25, 0.3, 0.4, 0.5], [0.0, 0.01, 0.1, 0.15], [0.0, 0.0, 0.0, 0.05]];
	return getQualityForThresholds([m.val | m <- unitSize.metrics],
									lineThresholds,
									relativeSizeThresholds,
									totalLinesOfCode);
}

Quality getUnitComplexityQuality(CodeProperty unitComplexity, list[int] riskThresholds) {
	// Risk wrt CC: low, moderate, high, very high	
	num totalComplexity = sum([m.val | m <- tail(unitComplexity.metrics)]);
	list[list[real]] relativeRiskThresholds = [[1.0, 1.0, 1.0, 1.0], [0.25, 0.3, 0.4, 0.5], [0.0, 0.01, 0.1, 0.15], [0.0, 0.0, 0.0, 0.05]];
	return getQualityForThresholds([m.val | m <- tail(unitComplexity.metrics)],
									riskThresholds,
									relativeRiskThresholds,
									totalComplexity);	
}

Quality getDuplicationQuality(CodeProperty duplication, list[int] thresholds) {	
	num duplicatedLines = duplication.metrics[0].val;
	num totalLinesOfCode = duplication.metrics[1].val;
	num duplicationPercentage = duplicatedLines / toReal(totalLinesOfCode);
	return getThresholdRank(duplicationPercentage * 100, thresholds);
}

list[CodePropertyEvaluation] computeCodeProperties(loc project) {
	datetime computationStart = now();	
	datetime stopwatch = now();
	list[CodePropertyEvaluation] ret = [<computeVolume(project), getVolumeQuality, [66, 246, 665, 1310]>];
	println("Volume computed in: <createDuration(stopwatch, now())>");
	
	stopwatch = now();
	ret = ret + <computeUnitSize(project), getUnitSizeQuality, [15, 30, 60]>;
	println("Unit size computed in: <createDuration(stopwatch, now())>");
	
	stopwatch = now();
	ret = ret + <computeUnitComplexity(project), getUnitComplexityQuality, [10, 20, 50]>;
	println("Unit complexity computed in: <createDuration(stopwatch, now())>");
	
	stopwatch = now();
	ret = ret + <computeDuplication(project), getDuplicationQuality, [3, 5, 10, 20]>;	
	println("Duplication computed in: <createDuration(stopwatch, now())>");
	
	println("All metrics computed in: <createDuration(computationStart, now())>");
	return ret;
}

MaintainabilityModel createMaintainabilityModel(list[CodePropertyEvaluation] props) {	
	return [
			<"Analysability", [pe | pe <- props, pe.property.name == "Volume" || pe.property.name == "Duplication" || pe.property.name == "UnitSize"]>,
			<"Testability", [pe | pe <- props, pe.property.name == "UnitComplexity" || pe.property.name == "UnitSize"]>,
			<"Changeability", [pe | pe <- props, pe.property.name == "Duplication" || pe.property.name == "UnitComplexity"]>
			];
}

Quality getSystemPropertyQuality(SystemProperty prop) {
	return sum([0] + [pe.evaluationFunc(pe.property, pe.thresholds) | pe <- prop.properties]) / size(prop.properties);
}

MaintainabilityModel computeModel(loc project) {
	return createMaintainabilityModel(computeCodeProperties(project));	
}


//////////////////////////////////////////////////
// Test code
//////////////////////////////////////////////////

void performanceTest() {
	loc project = |project://hsqldb-2.3.1/hsqldb/src|;
	computeModel(project);
}

void computeModel() {
	loc project = |project://smallsql0.21/src|;
	iprintln(computeModel(project));
}
