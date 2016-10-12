package dk.itu.models.reporting

import dk.itu.models.Settings
import java.io.ByteArrayOutputStream
import java.io.PrintStream
import java.util.ArrayList

import static extension dk.itu.models.Extensions.*
import java.io.File

class FileRecord {
	
	public val String filename
	
	public val String consoleOutput
	public val int errorCount
	
	public val boolean processed
	public val boolean folder
	
	public var ArrayList<FileRecord> files
	
	public var int fileCount = 0
	
	new(String filename, String consoleOutput, boolean processed, boolean folder, int errorCount) {
		this.filename = filename
		this.consoleOutput = consoleOutput
		this.processed = processed
		this.folder = folder
		
		this.errorCount = errorCount
		
		if (folder) files = new ArrayList<FileRecord>
	}
	
	
	
	def void addFile (FileRecord file) {
		files.add(file)
	}
	
	
	
	def void writeAllFiles (File targetFolder) {
		if (folder) {
			files.forEach[writeAllFiles(targetFolder)]
		
			println("report folder: " + targetFolder + filename + "/index.htm")
			updateFileCount
			writeHTMLFile(targetFolder + filename + "/index.htm")
		} else {
			println("report file  : " + targetFolder + filename + ".htm")
			writeHTMLFile(targetFolder + filename + ".htm")
		}
	}
	
	
	
	def void writeHTMLFile (String outputFilename) {
		
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
<body>
<a href="file:///«Settings::targetFile»/index.htm">ROOT</a><br/>''')

		if (!folder) {
			ps.println(consoleOutput.replaceAll("(\r\n|\n)", "<br />"))
		} else {
			ps.println("<table>")
			files.sortBy[!it.folder].sortBy[!it.processed].forEach[ps.println(
'''
<tr>
	<td>«IF it.processed»<a href="file:///«Settings::targetFile + it.filename»«IF it.folder»/index«ENDIF».htm">«ENDIF».«filename»«IF it.folder»/«ENDIF»«IF it.processed»</a>«ENDIF»</td>
	<td>«IF it.folder»«it.fileCount»«ENDIF»</td>
	<td>«IF !it.folder»«it.errorCount»«ENDIF»</td>
<tr>''')]
			ps.println("</table>")
		}

		ps.print(
'''</body>
</html>''')

		baos.toString.writeToFile(outputFilename)
	}
	
	
	def void updateFileCount () {
		files.forEach[
			if (it.folder)
				this.fileCount += it.fileCount
			else
				this.fileCount++
		]
	}
}