package dk.itu.models.reporting

import java.io.ByteArrayOutputStream
import java.io.PrintStream
import java.util.ArrayList

import static extension dk.itu.models.Extensions.*

class FileRecord {
	
	public val String filename
//	
//	public val String consoleOutput
//	public val int errorCount
//	
//	public val boolean processed
	public val boolean folder
	public val ArrayList<ErrorRecord> errors
//	
//	public var ArrayList<FileRecord> files
//	
//	public var int fileCount = 0
//	
	new(String filename, boolean folder, ArrayList<ErrorRecord> errors) {
		this.filename = filename
		this.folder = folder
		this.errors = errors
	}	
	
//	new(String filename, String consoleOutput, boolean processed, boolean folder, int errorCount) {
//		this.filename = filename
//		this.consoleOutput = consoleOutput
//		this.processed = processed
//		this.folder = folder
//		
//		this.errorCount = errorCount
//		
//		if (folder) files = new ArrayList<FileRecord>
//	}
//	
//	
//	
//	def void addFile (FileRecord file) {
//		files.add(file)
//	}
//	
//	
//	
//	def void writeAllFiles (File targetFolder) {
//		if (folder) {
//			files.forEach[writeAllFiles(targetFolder)]
//		
//			println("report folder: " + targetFolder + filename + "/index.htm")
//			updateFileCount
//			writeHTMLFile(targetFolder + filename + "/index.htm")
//		} else {
//			println("report file  : " + targetFolder + filename + ".htm")
//			writeHTMLFile(targetFolder + filename + ".htm")
//		}
//	}
//	
//	
//	
	def void writeFile (String outputFilename, Report report) {
		
		val baos = new ByteArrayOutputStream()
		val ps = new PrintStream(baos)
		
		ps.print(
'''<html>
<head>
<style>
table, th, td {
    border: 1px solid black;
}
</style>
</head>
<body>''')
//<a href="file:///«Settings::targetFile»/index.htm">ROOT</a><br/>''')


		if (!folder) {
			errors.forEach[ps.println(error.replaceAll("(\r\n|\n)", "<br />") + "<br />")]
//			ps.println(consoleOutput.replaceAll("(\r\n|\n)", "<br />"))
		} else {
			ps.println("<table>")
			report.fileRecords.filter[filename.startsWith(this.filename)].sortBy[filename].forEach[ps.println(
'''
<tr>
	<td>.«filename»</td>
	«IF folder»<td></td>«ELSE»<td>«IF errors.exists[error.contains("Reconfigurator no AST")]»No AST«ENDIF»</td>«ENDIF»
	«IF folder»<td></td>«ELSE»<td>«errors.size» errors: «errors.filter[error.startsWith("error:(1)")].size» x (1), «errors.filter[error.startsWith("error:(5)")].size» x (5), «errors.filter[error.startsWith("error:(9)")].size» x (9), «errors.filter[error.startsWith("Exception")].size» x Exception(s)</td>«ENDIF»
<tr>''')]
			ps.println("</table>")
		}

		ps.print(
'''</body>
</html>''')

		baos.toString.writeToFile(outputFilename)
	}
//	
//	
//	def void updateFileCount () {
//		files.forEach[
//			if (it.folder)
//				this.fileCount += it.fileCount
//			else
//				this.fileCount++
//		]
//	}
}