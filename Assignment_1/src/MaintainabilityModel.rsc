module MaintainabilityModel

import util::Math;
import List;
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
	return size([x | x <- thresholds, valueRanked < x]) + 1;
}

Quality getVolumeQuality(CodeProperty volume) {
	list[int] thresholds = [66, 246, 665, 1310];
	num linesOfCodeInThousands = volume.metrics[0].val / 1000;
	return getThresholdRank(linesOfCodeInThousands, thresholds);
}

Quality getUnitSizeQuality(CodeProperty unitSize) {
	// Classification derived from Better Code hub because it is not in the paper
	list[int] lineThresholds = [15, 30, 60];
	int totalLinesOfCode = sum([toInt(x) | x <- unitSize.metrics.val]);
	
	// TODO: 
	// 1. classify the functions by risk category depending on the threshold
	rel[int, int] linecountByThreshold = {<getThresholdRank(m.val), m.val> | m <- unitSize.metrics};
	// 2. make a rel[threshold, linecount]
	//rel[int, int] aggregatedLineByThreshold = {domain(linecountByThreshold)
	// 3. collapse the relation by aggregating the threshold values so that we get
	// 4. transform the aggregated rel to a list of percentages (size categories) 
	list[real] sizeCategories = [0.12, 0.023, 0.02, 0.122];			// Test data
	
	return MinQuality;
}

Quality getUnitComplexityQuality(CodeProperty unitComplexity) {
	// risk wrt CC: low, moderate, high, very high
	list[int] riskThresholds = [1, 11, 21, 51];
	
	// risk thresholds wrt quality ratings
	// TODO: classify the 
	list[real] riskCategories = [0.45, 0.023, 0.02, 0.122];		// Test data
	list[real] relativeRiskThresholds_Moderate = [0.25, 0.3, 0.4, 0.5];
	list[real] relativeRiskThresholds_High = [0.0, 0.01, 0.1, 0.15];
	list[real] relativeRiskThresholds_VeryHigh = [0.0, 0.0, 0.0, 0.05];
	list[int] qualitiesPerRiskCategory = [getThresholdRank(riskCategories[1], relativeRiskThresholds_Moderate),
										  getThresholdRank(riskCategories[2], relativeRiskThresholds_High),
									      getThresholdRank(riskCategories[3], relativeRiskThresholds_VeryHigh)];
	
	return min(qualitiesPerRiskCategory);
}

Quality getDuplicationQuality(CodeProperty duplication) {
	// TODO: usage table to grade
	list[real] thresholds = [0.03, 0.05, 0.1, 0.2];
	real duplicationPercentage = 0.12;	// Test data
	return getThresholdRank(duplicationPercentage, thresholds);
}

list[CodePropertyEvaluation] computeCodeProperties(loc project) {
	return [<computeVolume(project), getVolumeQuality>,
			<computeUnitSize(project), getUnitSizeQuality>,
			<computeUnitComplexity(project), getUnitComplexityQuality>,
			<computeDuplication(project), getDuplicationQuality>];
}

list[SystemProperty] createSystemProperties(list[CodePropertyEvaluation] props) {
	SystemProperty stability = <"Stability", []>;
	SystemProperty analysability = <"Analysability", [pe | pe <- props, pe.property.name == "Volume" || pe.property.name == "Duplication" || pe.property.name == "UnitSize"]>;
	SystemProperty testability = <"Testability", [pe | pe <- props, pe.property.name == "UnitComplexity" || pe.property.name == "UnitSize"]>;
	SystemProperty changeability = <"Changeability", [pe | pe <- props, pe.property.name == "Duplication" || pe.property.name == "UnitComplexity"]>;
	return [stability, analysability, testability, changeability];
}

Quality getSystemPropertyQuality(SystemProperty prop) {
	return sum([0] + [pe.evaluationFunc(pe.property) | pe <- prop.properties]) / size(prop.properties);
}

void computeModel(loc project) {
	list[CodePropertyEvaluation] codeProperties = computeCodeProperties(project);
	list[SystemProperty] systemProperties = createSystemProperties(codeProperties);
	//iprintln([<sp.name, getSystemPropertyQuality(sp), [<cp.property.name, cp.evaluationFunc(cp.property)> | cp <- sp.properties]> | sp <- systemProperties]);
	// TODO: visualize the model?
}

void computeModel() {
	loc project0 = |project://smallsql0.21/|;
	computeModel(project0);
}
