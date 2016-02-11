package dk.itu.models.tests

import java.util.List
import xtc.lang.cpp.SuperC
import itu2.RemOneRule
import dk.itu.models.TxPrintCode
import itu2.Strategy
import itu2.BottomUpStrategy
import itu2.MergeSeqI
import dk.itu.models.TxPrintAst
import xtc.tree.Node
import itu2.RemExtraRule
import xtc.lang.cpp.PresenceConditionManager

class Test1 extends Test {
	
	val protected String file
	
	new (String inputFile) {
		this.file = inputFile
	}
	
	override void run(List<String> args)
	{
		var List<String> newArgs = args.clone
		newArgs.add(file)
		new SuperC().run(newArgs)
	}

	override transform(Node node, PresenceConditionManager presenceConditionManager)
	{
		  val boolean PRINT_HASH_CODE = true
		  val boolean DONT_PRINT_HASH_CODE = false
		  
		  var TxPrintAst txPrintAst = new TxPrintAst(presenceConditionManager)
		  var TxPrintCode txPrintCode = new TxPrintCode(presenceConditionManager)
		  var String out1
		  var String out2
		  
		  // test that the empty BottomUpStrategy is identity
		  out1 = txPrintAst.transform(node, PRINT_HASH_CODE)
		  writeToFile(out1, "test\\003\\ast.c")
		  
		  out2 = txPrintCode.transform(node)
		  writeToFile(out2, "test\\003\\out.c")
		  
		  var Strategy bus = new BottomUpStrategy(presenceConditionManager)
		  var Node test = bus.visit(node) as Node
		  out2 = txPrintAst.transform(test, PRINT_HASH_CODE)
		  writeToFile(out2, "test\\003\\ast_id.c")
		  
		  if(out1.equals(out2))
			  println("the empty BottomUpStrategy is identity PASS")
		  else
			  println("the empty BottomUpStrategy is identity FAIL")
			  
		  println("\n\n")
		  
		  // test RemOneRule
		  bus.register(new RemOneRule())
		  bus.register(new RemExtraRule())
		  bus.register(new MergeSeqI())
		  test = bus.visit(node) as Node
		  out2 = txPrintCode.transform(test)
		  writeToFile(out2, "test\\003\\final.c")
		  out2 = txPrintAst.transform(test, DONT_PRINT_HASH_CODE)
		  writeToFile(out2, "test\\003\\ast_final.c")
	}
	
}