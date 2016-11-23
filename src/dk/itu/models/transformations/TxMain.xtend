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
						
		debug("PHASE 1 - Normalize")
		var Node node1 = node
		val tdn1 = new TopDownStrategy
		tdn1.register(new RemActionRule)
		tdn1.register(new NormalizeRule)
		node1 = tdn1.transform(node1) as Node
		writeToFile(node1.printCode, Settings::targetFile.path)
		if (Settings::printIntermediaryFiles) {
			writeToFile(node1.printCode, Settings::targetFile + ".phase1.c")
			writeToFile(node1.printAST, Settings::targetFile + ".phase1.ast")
		}




		debug("PHASE 2 - Prepare for reconfiguration")
		val tdn2 = new TopDownStrategy
		tdn2.register(new IsolateDeclarationRule)
		val Node node2 = tdn2.transform(node1) as Node
		writeToFile(node2.printCode, Settings::targetFile.path)
		if (Settings::printIntermediaryFiles) {
			writeToFile(node2.printCode, Settings::targetFile + ".phase2.c")
			writeToFile(node2.printAST, Settings::targetFile + ".phase2.ast")
		}


		var Node node4 = node2
		if (!Settings::parseOnly) {
			debug("PHASE 3,4 - Reconfigure declarations")
			val tdnQ = new TopDownStrategy
			tdnQ.register(new ReconfigureDeclarationRule)
			node4 = tdnQ.transform(node2) as Node
			writeToFile(node4.printCode, Settings::targetFile.path)
			if (Settings::printIntermediaryFiles) {
				writeToFile(node4.printCode, Settings::targetFile + ".phase_.c")
				writeToFile(node4.printAST, Settings::targetFile + ".phase_.ast")
			}
		}





		debug("PHASE 5 - Cleanup")
		val tdn5 = new TopDownStrategy
		tdn5.register(new RemergeConditionalsRule)
		var Node node5 = tdn5.transform(node4) as Node
		writeToFile(node5.printCode, Settings::targetFile.path)
		if (Settings::printIntermediaryFiles) {
			writeToFile(node5.printCode, Settings::targetFile + ".phase5.c")
			writeToFile(node5.printAST, Settings::targetFile + ".phase5.ast")
		}



		var Node node6 = node5
		if (!Settings::parseOnly) {
			debug("PHASE 6 - #ifdef to if")
			val tdn6 = new TopDownStrategy
			tdn6.register(new Ifdef2IfRule)
			node6 = tdn6.transform(node5) as Node
			writeToFile(node6.printCode, Settings::targetFile.path)
			if (Settings::printIntermediaryFiles) {
				writeToFile(node6.printCode, Settings::targetFile + ".phase6.c")
				writeToFile(node6.printAST, Settings::targetFile + ".phase6.ast")
			}
		}



		return node6
	}
	
}