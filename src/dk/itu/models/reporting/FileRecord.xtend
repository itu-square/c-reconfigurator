package dk.itu.models.reporting

class FileRecord {
	
	public val String filename
	public val String consoleOutput
	
	new(String filename, String consoleOutput) {
		this.filename = filename
		this.consoleOutput = consoleOutput
	}
}