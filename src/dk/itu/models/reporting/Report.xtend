package dk.itu.models.reporting

import java.util.ArrayList
import static extension dk.itu.models.Extensions.*
import java.io.ByteArrayOutputStream
import java.io.PrintStream
import java.io.File

class Report {
	
	public val fileRecords = new ArrayList<FileRecord>
//	val errorRecords = new ArrayList<ErrorRecord>
	
	def void addFile(String filename, ArrayList<ErrorRecord> errors) {
		fileRecords.add(new FileRecord(filename, false, errors))
	}
	
	def void addFolder(String filename) {
		fileRecords.add(new FileRecord(filename, true, null))
	}
	
//	def void addFileRecord(String filename, String consoleOutput, boolean processed, boolean folder) {
//		fileRecords.add(new FileRecord(filename, consoleOutput, processed, folder))
//	}
//	
//	def void addErrorRecord(String error, String filename) {
//		var er = errorRecords.findFirst[it.error.equals(error)]
//		
//		if (er == null) {
//			er = new ErrorRecord(error, filename)
//			errorRecords.add(er)
//		} else {
//			er.filenames.add(filename)
//		}
//	}
	
	
	def void writeFiles(File sourceRoot, File targetRoot) {
		
		println("\n\n\n")
		println("Writing report")
		
		fileRecords.sortBy[filename].forEach[
			if(folder) {
				println('''reporting folder «targetRoot»«filename»/index.htm''')
				writeFile('''«targetRoot»«filename»/index.htm''', this)
			} else {
				println('''reporting file   «targetRoot»«filename».htm''')
				writeFile('''«targetRoot»«filename».htm''', this)
			}
		]
		
		
//		val baos = new ByteArrayOutputStream()
//		val ps = new PrintStream(baos)
//		
//		ps.println(
//'''<html>
//<head>
//<style>
//table, th, td {
//    border: 1px solid black;
//}
//</style>
//</head>
//<body>
//<table>''')
//		
//		fileRecords.filter[it.processed == processed].forEach[ps.println(
//'''  <tr>
//    <td>«filename»</td>
//    <td>«consoleOutput.replaceAll("(\r\n|\n)", "<br />")»</td>
//  <tr>''')]
//		
//		ps.println(
//'''</table>
//</body>
//</html>''')
//		
//		baos.toString.writeToFile(outputFilename)
//	}
//	
//	
//		def void writeErrors(String outputFilename) {
//		val baos = new ByteArrayOutputStream()
//		val ps = new PrintStream(baos)
//		
//		ps.println(
//'''<html>
//<head>
//<style>
//table, th, td {
//    border: 1px solid black;
//}
//</style>
//</head>
//<body>
//<table>''')
//		
//		errorRecords.sortBy[-filenames.length].forEach[ps.println(
//'''  <tr>
//    <td>«error»</td>
//    <td>«FOR filename : filenames»«filename»</br>«ENDFOR»</td>
//  <tr>''')]
//		
//		ps.println(
//'''</table>
//</body>
//</html>''')
//		
//		baos.toString.writeToFile(outputFilename)
	}
}