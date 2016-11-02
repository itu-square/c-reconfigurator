package dk.itu.models.transformations

import dk.itu.models.Settings
import dk.itu.models.rules.ReconfigureDeclarationRule
import dk.itu.models.rules.phase1normalize.NormalizeRule
import dk.itu.models.rules.phase1normalize.RemActionRule
import dk.itu.models.rules.phase2prepare.IsolateDeclarationRule
import dk.itu.models.rules.phase5cleanup.RemergeConditionalsRule
import dk.itu.models.rules.phase6ifdefs.Ifdef2IfRule
import dk.itu.models.strategies.TopDownStrategy
import xtc.tree.Node

import static extension dk.itu.models.Extensions.*

class TxMain extends Transformation {
	
	override Node transform(Node node) {
						
		println("PHASE 0 - Print base")
//		writeToFile(node.printCode, file + ".phase0.c")
//		writeToFile(node.printAST, file + ".phase0.ast")
		
		
		
		println("PHASE 1 - Normalize")
		var Node node1 = node
		
		val tdn1 = new TopDownStrategy
		tdn1.register(new RemActionRule)
		tdn1.register(new NormalizeRule)
		node1 = tdn1.transform(node1) as Node
		
//		if(node1.checkContainsIf1) return;
		
//		writeToFile(node1.printCode, file + ".phase1.c")
		writeToFile(node1.printAST, Settings::targetFile + ".phase1.ast")





		println("PHASE 2 - Prepare for reconfiguration")
		val tdn2 = new TopDownStrategy
		tdn2.register(new IsolateDeclarationRule)
		val Node node2 = tdn2.transform(node1) as Node
//		writeToFile(node2.printCode, file + ".phase2.c")
		writeToFile(node2.printAST, Settings::targetFile + ".phase2.ast")





		println("PHASE ? - Reconfigure declarations")
		val tdnQ = new TopDownStrategy
		tdnQ.register(new ReconfigureDeclarationRule)
		var Node node4 = tdnQ.transform(node2) as Node
//		writeToFile(node4.printCode, file + ".phase4.c")
		writeToFile(node4.printAST, Settings::targetFile + ".phase_.ast")

//		println("PHASE 3 - Reconfigure variables")
//		val pcidmap = new HashMap<PresenceCondition, String>		
//		val reconfigureVariableRule = new ReconfigureVariableRule(pcidmap)
//		val tdn3 = new TopDownStrategy
//		tdn3.register(reconfigureVariableRule)
//		var Node node3 = tdn3.transform(node2) as Node
////		writeToFile(node3.printCode, file + ".phase3.c")
////		writeToFile(node3.printAST, file + ".phase3.ast")
//
//
//
//
//
//		println("PHASE 4 - Reconfigure functions")
//		val tdn4 = new TopDownStrategy
//		tdn4.register(new ReconfigureFunctionRule(pcidmap))
//		var Node node4 = tdn4.transform(node3) as Node
////		writeToFile(node4.printCode, file + ".phase4.c")
////		writeToFile(node4.printAST, file + ".phase4.ast")





		println("PHASE 5 - Cleanup")
		val tdn5 = new TopDownStrategy
		tdn5.register(new RemergeConditionalsRule)
//		tdn5.register(new Specific_ExtractRParenFromConditionalRule)
		var Node node5 = tdn5.transform(node4) as Node
//		writeToFile(node5.printCode, file + ".phase5.c")
		writeToFile(node5.printAST, Settings::targetFile + ".phase5.ast")





		println("PHASE 6 - #ifdef to if")
		val tdn6 = new TopDownStrategy
		tdn6.register(new Ifdef2IfRule)
		var Node node6 = tdn6.transform(node5) as Node
//		writeToFile(node6.printCode, file + ".phase6.c")
		writeToFile(node6.printAST, Settings::targetFile + ".phase6.ast")





		val Node result = node6
//		writeToFile('''#include "«Settings::reconfigFile»"«"\n" + result.printCode»''', file)
//		writeToFile(result.printAST, file + ".ast")
		
		
		// check #if elimination
//		println('''result: «IF result.containsConditional»#if«ELSE»no#if«ENDIF»''')

		// check oracle
//		if(Settings::oracleFile != null) {
//			val oracle = file.replace(Settings::targetFile.path, Settings::oracleFile.path) + ".ast"
//			if((new File(oracle)).exists)
//				if(result.printAST.equals(readFile(oracle)))
//					println("oracle: pass")
//				else
//					println("oracle: fail")
//		}

		return result
	}
	
}