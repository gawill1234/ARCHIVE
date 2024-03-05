package helperFunctions;


import java.net.MalformedURLException;




import jcifs.Config;
import jcifs.smb.SmbException;
import jcifs.smb.SmbFile;


public class SMB {
	public String host = "testbed5.test.vivisimo.com";
	public String dir = "testfiles/samba_test_data/pushpa/test_documents/";	
	public String pwd = "mustang5";
	public String userName = "root";
	public SmbFile[] files;
	public SmbFile smbFileDir;

	public SMB(String _host, String _path, String _userName, String _pwd) throws MalformedURLException {
		this.host = _host;
		this.dir = _path;
		this.userName = _userName;
		this.pwd = _pwd;
		initialize();

	}

	public SMB() throws MalformedURLException {
		initialize();

	}

	

	private void initialize() throws MalformedURLException {
		Config.setProperty("jcifs.smb.client.username", userName);
		Config.setProperty("jcifs.smb.client.password", pwd);
		
		String smb_path = "smb://" + this.host + "/" + this.dir;
		this.smbFileDir = new SmbFile(smb_path);
		files = new SmbFile[0];
	}

	public void listOfFiles() throws SmbException {

		files = new SmbFile[0];
		if (smbFileDir.isDirectory()) {		
		files = smbFileDir.listFiles();			
			
		}
		
	}
	
	
	public int noofFiles() throws SmbException {
		listOfFiles();
		return this.files.length;
	}

	public SmbFile[] getFiles() throws SmbException {
		listOfFiles();
		return files;
	}

	

	public SmbFile getSmbFileDir() {
		return smbFileDir;
	}

}
