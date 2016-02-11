package dk.itu.models.tests

import java.io.PrintWriter
import java.io.FileOutputStream
import java.io.IOException
import java.util.List
import xtc.tree.Node
import xtc.lang.cpp.PresenceConditionManager

abstract class Test {
	
  protected def void writeToFile(String text, String file) {
      try {
	  	var PrintWriter file_output = new PrintWriter(new FileOutputStream(file));
	  	file_output.write(text);
	  	file_output.flush();
	  	file_output.close();
      } catch (IOException e) {
    	  System.err.println("Can not recover from the input or output fault");
	  }
  }
  
  def void run(List<String> args)	
  
  def void transform(Node node, PresenceConditionManager presenceConditionManager)
	
}