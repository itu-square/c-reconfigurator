package dk.itu.models.reporting

import java.util.ArrayList

class ErrorRecord {
	
	public val String error
//	public val ArrayList<String> filenames
	
	new(String error) {
		this.error = error
	}

//	new(String error, String filename) {
//		this.error = error
//		this.filenames = new ArrayList<String>
//		filenames.add(filename)
//	}
//	
//	def void addFilename (String filename) {
//		filenames.add(filename)
//	}
}