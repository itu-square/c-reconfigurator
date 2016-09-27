package dk.itu.models.reporting

import java.util.ArrayList
import static extension dk.itu.models.Extensions.*
import java.io.ByteArrayOutputStream
import java.io.PrintStream

class Report {
	
	var fileRecords = new ArrayList<FileRecord>
	var errorRecords = new ArrayList<ErrorRecord>
	
	def void addFileRecord(String filename, String consoleOutput) {
		fileRecords.add(new FileRecord(filename, consoleOutput))
	}
	
	def void addErrorRecord(String error, String filename) {
		var er = errorRecords.findFirst[it.error.equals(error)]
		
		if (er == null) {
			er = new ErrorRecord(error, filename)
			errorRecords.add(er)
		} else {
			er.filenames.add(filename)
		}
	}
	
	def void writeFiles(String outputFilename) {
		val baos = new ByteArrayOutputStream()
		val ps = new PrintStream(baos)
		
		ps.println(
'''<html>
<head>
<style>
table, th, td {
    border: 1px solid black;
}
</style>
</head>
<body>
<table>''')
		
		fileRecords.forEach[ps.println(
'''  <tr>
    <td>«filename»</td>
    <td>«consoleOutput.replaceAll("(\r\n|\n)", "<br />")»</td>
  <tr>''')]
		
		ps.println(
'''</table>
</body>
</html>''')
		
		baos.toString.writeToFile(outputFilename)
	}
	
	
		def void writeErrors(String outputFilename) {
		val baos = new ByteArrayOutputStream()
		val ps = new PrintStream(baos)
		
		ps.println(
'''<html>
<head>
<style>
table, th, td {
    border: 1px solid black;
}
</style>
</head>
<body>
<table>''')
		
		errorRecords.sortBy[-filenames.length].forEach[ps.println(
'''  <tr>
    <td>«error»</td>
    <td>«FOR filename : filenames»«filename»</br>«ENDFOR»</td>
  <tr>''')]
		
		ps.println(
'''</table>
</body>
</html>''')
		
		baos.toString.writeToFile(outputFilename)
	}
}