package dk.itu.models.tests

import dk.itu.models.Settings
import dk.itu.models.rules.ReconfigureFunctionRule
import dk.itu.models.rules.RemExtraRule
import dk.itu.models.rules.normalize.ConditionPushDownRule
import dk.itu.models.rules.normalize.ConstrainNestedConditionalsRule
import dk.itu.models.rules.normalize.MergeSequentialMutexConditionalRule
import dk.itu.models.rules.normalize.RemOneRule
import dk.itu.models.rules.normalize.SplitConditionalRule
import dk.itu.models.rules.variables.ReconfigureVariableRule
import dk.itu.models.strategies.TopDownStrategy
import java.io.File
import xtc.tree.Node

import static extension dk.itu.models.Extensions.*

class Test3 extends Test {

	new(String inputFile) {
		super(inputFile)
	}

	override transform(Node node) {
////		println(file)
		writeToFile(node.printCode, file + "base.c")
		writeToFile(node.printAST, file + "base.c.ast")

		println("PHASE 1 - Normalize")
		
		val tdn = new TopDownStrategy
		tdn.register(new RemOneRule)
		tdn.register(new RemExtraRule)
		tdn.register(new MergeSequentialMutexConditionalRule)
		tdn.register(new ConstrainNestedConditionalsRule)
		tdn.register(new SplitConditionalRule)
		tdn.register(new ConditionPushDownRule)
//
		var Node normalized = tdn.transform(node) as Node
		writeToFile(normalized.printCode, file + "norm.c")
		writeToFile(normalized.printAST, file + "norm.ast")
		
		
		
		println("PHASE 2 - Reconfigure variables")
		
		val tdn1 = new TopDownStrategy
		tdn1.register(new ReconfigureVariableRule)
		
		
		var Node varReconfigured = tdn1.transform(normalized) as Node
		writeToFile('''#include "«Settings::reconfigFile»"«"\n" + varReconfigured.printCode»''', file + ".var.c")
		writeToFile(varReconfigured.printAST, file + ".var.c.ast")
		
		println("PHASE 3 - Reconfigure functions")

		val tdn2 = new TopDownStrategy
		tdn2.register(new ReconfigureFunctionRule)

		var Node funReconfigured = tdn2.transform(varReconfigured) as Node
		writeToFile('''#include "«Settings::reconfigFile»"«"\n" + funReconfigured.printCode»''', file)
		writeToFile(funReconfigured.printAST, file + ".ast")
		
		
//		val tdn2 = new TopDownStrategy
//		tdn2.register(new PrintScopeRule)
//		tdn2.transform(funextracted)

		// check #if elimination
		println('''result: «IF funReconfigured.containsConditional»#if«ELSE»   «ENDIF»''')

		// check oracle
		if(Settings::oracleFile != null) {
			val oracle = file.replace(Settings::targetFile.path, Settings::oracleFile.path) + ".ast"
			if((new File(oracle)).exists)
				if(funReconfigured.printAST.equals(readFile(oracle)))
					println("oracle: pass")
				else
					println("oracle: fail")
		}
	}

}