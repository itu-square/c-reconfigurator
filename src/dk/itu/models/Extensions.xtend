package dk.itu.models

import java.io.File
import java.io.PrintWriter
import java.io.FileOutputStream
import java.io.IOException

class Extensions {
	public static def String folder(String filePath) {
		filePath.substring(0, filePath.lastIndexOf(File.separator) + 1)
	}
	
	public static def String relativeTo(String path, String base) {
		if (path.startsWith(base)) { '''«path.substring(base.length)»''' }
		else path
	}
	
	public static def void writeToFile(String text, String file) {
		try {
			var PrintWriter file_output = new PrintWriter(new FileOutputStream(file));
			file_output.write(text);
			file_output.flush();
			file_output.close();
		} catch (IOException e) {
			System.err.println("Can not recover from the input or output fault");
		}
	}
	
	public static def void print(Object o) {
		System.out.print(o)
		Settings::systemOutPS.flush
	}
	
	public static def void println(Object o) {
		print(o + "\n")
	}
	
	public static def void println() {
		print("\n")
	}
}