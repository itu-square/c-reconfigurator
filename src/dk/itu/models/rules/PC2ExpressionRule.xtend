package dk.itu.models.rules

import xtc.lang.cpp.CTag
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.tree.GNode
import xtc.util.Pair
import dk.itu.models.Reconfigurator
import java.io.Writer
import java.io.IOException
import java.util.List
import net.sf.javabdd.BDD

class PC2ExpressionRule extends Rule {

	def void t(BDD bdd) {
	  val vars = Reconfigurator.presenceConditionManager.variableManager
      var List allsat;
      var Boolean firstTerm;

      if (bdd.isOne()) {
        print("1");
        return;
      } else if (bdd.isZero()) {
        print("0");
        return;
      }
      
      allsat = bdd.allsat() as List;
      
      firstTerm = true;
      for (Object o : allsat) {
        var byte[] sat;
        var Boolean first;
        
        if (! firstTerm) {
          print(" || ");
        }
        
        firstTerm = false;

        sat = o as byte[];
        first = true;
        for (var i = 0; i < sat.length; i++) {
          if (sat.get(i) >= 0 && ! first) {
            print(" && ");
          }
          switch (sat.get(i)) {
            case 0 as byte: {
              print("!")
              print(vars.getName(i))
              first = false
            }
            case 1 as byte: {
              print(vars.getName(i))
              first = false
            }
          }
        }
      }
    }
	
	override dispatch PresenceCondition transform(PresenceCondition cond) {
		println(cond)
			
//		val vars = Reconfigurator.presenceConditionManager.variableManager
//		
//		val allsat = cond.BDD.allsat()
//		
//		val str = new StringBuilder
//		var firstTerm = true
//		for (Object o : allsat) {
//			//
//			if (!firstTerm) str.append(" || ")
//			firstTerm = false;
//			//
//			val sat = o as byte[]
//			var firstVar = true
//			for (var i = 0; i < sat.length; i++) {
//				if (sat.get(i)>=0 && !firstVar) str.append(" && ")
//				switch(sat.get(i)) {
//					case 0 as byte: {
//						print('''[«i»]«sat.get(i)» is !, ''')
//						str.append("!")
//					}
//					case 1 as byte: {
//						print('''[«i»]«sat.get(i)» is «vars.getName(i)», ''')
//						str.append(vars.getName(i))
//						firstVar = false
//					}
//				}	
//			}	
//			println
//		}
//		println(str)
		
		t(cond.BDD)
		println
		println
		cond
	}

	override dispatch Language<CTag> transform(Language<CTag> lang) {
		lang
	}

	override dispatch Pair<?> transform(Pair<?> pair) {
		pair
	}
	
	override dispatch Object transform(GNode node) {
		node
	}

}