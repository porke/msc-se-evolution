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

Quality getVolumeQuality(CodeProperty volume) {
	list[int] thresholds = [66, 246, 665, 1310];
	num linesOfCodeInThousands = volume.metrics[0].val / 1000;
	list[int] finalMetric = [x | x <- thresholds, linesOfCodeInThousands < x];	
	return size(finalMetric) + 1;
}

Quality getUnitSizeQuality(CodeProperty unitSize) {
	// TODO: usage table to grade
	// Classification derived from Better Code hub because it is not in the paper:
	// 60+ lines -> very high risk 
	// 30+ lines -> high risk
	// 15+ lines -> medium risk
	// less than 15 lines -> low risk 
	return MinQuality;
}

Quality getUnitComplexityQuality(CodeProperty unitComplexity) {
	// TODO: usage table to grade
	return MinQuality;
}

Quality getDuplicationQuality(CodeProperty duplication) {
	// TODO: usage table to grade
	return MinQuality;
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
