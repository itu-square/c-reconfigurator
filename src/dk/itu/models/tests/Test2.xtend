package dk.itu.models.tests

import dk.itu.models.Settings
import dk.itu.models.rules.Ifdef2IfRule
import dk.itu.models.rules.ReconfigureFunctionRule
import dk.itu.models.rules.RemExtraRule
import dk.itu.models.rules.RemNestedMutexConditionalRule
import dk.itu.models.rules.normalize.ConditionPushDownRule
import dk.itu.models.rules.normalize.MergeSequentialMutexConditionalRule
import dk.itu.models.rules.normalize.RemOneRule
import dk.itu.models.rules.normalize.SplitConditionalRule
import dk.itu.models.rules.variables.ReconfigureVariableRule
import dk.itu.models.strategies.TopDownStrategy
import java.io.File
import xtc.tree.Node

import static extension dk.itu.models.Extensions.*
import java.util.HashMap
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition

class Test2 extends Test {

	new(String inputFile) {
		super(inputFile)
	}

	override transform(Node node) {
//		println(file)
		writeToFile(node.printCode, file + "base.c")
//		writeToFile(node.printAST, file + ".ast")

		var tdn = new TopDownStrategy()
		tdn.register(new RemOneRule)
		tdn.register(new RemExtraRule)
		tdn.register(new MergeSequentialMutexConditionalRule)
		tdn.register(new RemNestedMutexConditionalRule)
		tdn.register(new SplitConditionalRule)
		tdn.register(new ConditionPushDownRule)

		var Node normalized = tdn.transform(node) as Node
		writeToFile(normalized.printCode, file + "norm.c")
		
		//println("PHASE 2 - Extract functions")

		tdn = new TopDownStrategy
		val extfRule = new ReconfigureFunctionRule(new HashMap<PresenceCondition, String>)
		tdn.register(extfRule)

		var Node funextracted = tdn.transform(normalized) as Node
		writeToFile(funextracted.printCode, file)
		
		//println("PHASE 3 - Extract variables")

		tdn = new TopDownStrategy
		val extVarRule = new ReconfigureVariableRule(new HashMap<PresenceCondition, String>)
		tdn.register(extVarRule)

		var Node varextracted = tdn.transform(funextracted) as Node
		writeToFile(varextracted.printCode, file + "var.c")
		writeToFile(varextracted.printAST, file + "var.ast")
		
		//println("PHASE 4 - Turn the rest ifdefs to ifs")
		
		tdn = new TopDownStrategy
		val ifdef2ifRule = new Ifdef2IfRule
		tdn.register(ifdef2ifRule)
		var Node ifdefextracted = tdn.transform(varextracted) as Node
		writeToFile(ifdefextracted.printCode, file)
		writeToFile(ifdefextracted.printAST, file + ".ast")
		
		
				// check #if elimination
		println('''result: «IF ifdefextracted.containsConditional»#if«ELSE»ok «ENDIF»''')

		// check oracle
		if(Settings::oracleFile != null) {
			val oracle = file.replace(Settings::targetFile.path, Settings::oracleFile.path) + ".ast"
			if((new File(oracle)).exists)
				if(funextracted.printAST.equals(readFile(oracle)))
					println("oracle: pass")
				else
					println("oracle: fail")
		}
		
	}

}