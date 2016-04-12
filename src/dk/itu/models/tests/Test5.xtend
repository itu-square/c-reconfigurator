package dk.itu.models.tests

import dk.itu.models.Settings
import dk.itu.models.rules.NormalizeRule
import dk.itu.models.rules.prepare.IsolateDeclarationRule
import dk.itu.models.rules.variables.ReconfigureVariableRule
import dk.itu.models.strategies.TopDownStrategy
import java.io.File
import xtc.tree.Node

import static extension dk.itu.models.Extensions.*
import java.util.HashMap
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import dk.itu.models.rules.ReconfigureFunctionRule
import dk.itu.models.rules.Ifdef2IfRule

class Test5 extends Test {
	
	new(String inputFile) {
		super(inputFile)
	}
	
	override transform(Node node) {
		
		writeToFile(node.printCode, file + ".base.c")
		writeToFile(node.printAST, file + ".base.ast")
		
		
		
		println("PHASE 1 - Normalize")
		var Node normalized = node
		
		val tdn0 = new TopDownStrategy
		tdn0.register(new NormalizeRule)
		normalized = tdn0.transform(normalized) as Node
		
//		val tdn1 = new TopDownStrategy
//		tdn1.register(new RemOneRule)
//		tdn1.register(new RemZeroRule)
//		tdn1.register(new SplitConditionalRule)
//		tdn1.register(new ConstrainNestedConditionalsRule)
//		tdn1.register(new ConditionPushDownRule)
//		tdn1.register(new MergeSequentialMutexConditionalRule)
//		normalized = tdn1.transform(normalized) as Node
		
		if(normalized.checkContainsIf1) return;
		
//		val tdn2 = new TopDownStrategy
//		tdn2.register(new MergeConditionalsRule)
//		tdn2.register(new OptimizeAssignmentExpressionRule)
//		normalized = tdn2.transform(normalized) as Node
		
		writeToFile(normalized.printCode, file + ".norm.c")
		writeToFile(normalized.printAST, file + ".norm.ast")
		
		
		
		
		
		
		
		println("PHASE 1.5 - Prepare for reconfiguration")
		
		val prepare_tdn = new TopDownStrategy
		prepare_tdn.register(new IsolateDeclarationRule)
		val Node prepared = prepare_tdn.transform(normalized) as Node
		writeToFile(prepared.printCode, file + ".prep.c")
		writeToFile(prepared.printAST, file + ".prep.ast")
		
		
		
		
		
		println("PHASE 2 - Reconfigure variables")
		val pcidmap = new HashMap<PresenceCondition, String>		
		val reconfigureVariableRule = new ReconfigureVariableRule(pcidmap)
		val tdn = new TopDownStrategy
		tdn.register(reconfigureVariableRule)
		
		
		var Node varReconfigured = tdn.transform(prepared) as Node
		writeToFile('''#include "«Settings::reconfigFile»"«"\n" + varReconfigured.printCode»''', file)
		writeToFile(varReconfigured.printAST, file + ".ast")
		
		
		
		
		
		
		
		
		println("PHASE 3 - Reconfigure functions")

		val tdn2 = new TopDownStrategy
		tdn2.register(new ReconfigureFunctionRule(pcidmap))

		var Node funReconfigured = tdn2.transform(varReconfigured) as Node
		writeToFile('''#include "«Settings::reconfigFile»"«"\n" + funReconfigured.printCode»''', file)
		writeToFile(funReconfigured.printAST, file + ".ast")
		
		
		
		
		
		println("PHASE 4 - #ifdef to if")
		
		
		val tdn4 = new TopDownStrategy
		tdn4.register(new Ifdef2IfRule)

		var Node allReconfigured = tdn4.transform(funReconfigured) as Node
		writeToFile('''#include "«Settings::reconfigFile»"«"\n" + allReconfigured.printCode»''', file)
		writeToFile(allReconfigured.printAST, file + ".ast")
		
		
		// check #if elimination
		println('''result: «IF allReconfigured.containsConditional»#if«ELSE»no#if«ENDIF»''')

		// check oracle
		if(Settings::oracleFile != null) {
			val oracle = file.replace(Settings::targetFile.path, Settings::oracleFile.path) + ".ast"
			if((new File(oracle)).exists)
				if(allReconfigured.printAST.equals(readFile(oracle)))
					println("oracle: pass")
				else
					println("oracle: fail")
		}
	}
	
}