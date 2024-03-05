
import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileFilter;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;

//
//   Build lists of directories or files.  Supply counts.
//
public class fileList
{
	private static String os;
	private static int batchSize;
	private static int batchCount;
		
	//
	//   Sets the user-selected object store from which
	//   folders will be retrieved.
	//
	public static void setOs(String os)
	{
		fileList.os = os;
	}
	
	//
	// Returns the current Object Store.
	//
	public static String getOs()
	{
		return os;
	}

        //
        //   Returns the array of the files contained in the 
        //   supplied directory.
        //
        public static File[] getFileList(File dir)
        {
                File[] files = dir.listFiles(new FileFilter()
                {
                        public boolean accept(File dir)
                        {
                                if (dir.isDirectory())
                                        return false;
                                else
                                        return true;
                        }
                });
                return files;
        }

	
	//
	//   Returns the array of the directories contained in the 
	//   supplied directory.
	//
	public static File[] getDirList(File dir)
	{
		File[] dirs = dir.listFiles(new FileFilter()
		{
			public boolean accept(File dir)
			{
				if (dir.isDirectory())
					return true;
				else
					return false;
			}
		});
		return dirs;
	}
	
	//
	//   Returns the batch size.
	//
	public static int getBatchSize()
	{
		return batchSize;
	}

	//
	//   Sets the batch size.
	//
	public static void setBatchSize(int batchSize)
	{
		fileList.batchSize = batchSize;
	} 
	
	//
	//   Calculates the batch count based on the count of files in supplied
	//   file system, whether subdirectories and batch size are 
        //   included or not.
	//
	public static void calculateBatchCount(String path, boolean includeSubDirectories)
	{
		File f = new File(path);
		File[] files = fileList.getFileList(f);
		File[] dirs = fileList.getDirList(f);
		int j = 0;
		j++;
		for(int i = 0; i < files.length; i++)
		{
			if (j <= getBatchSize())
			{
				j++;
			}
			if (j == getBatchSize() || i == files.length - 1)
			{
				++batchCount;
				j = 0;
			}
		}
		if(includeSubDirectories)
		{
			for(int k = 0; k < dirs.length; k++)
			{
				calculateBatchCount(dirs[k].getPath(),includeSubDirectories);
			}
		}
	}
	
	//
	//   Returns the batch count.
	//
	public static int getBatchCount()
	{
		return batchCount;
	}

	//
	//   Sets the batch count.
	//
	public static void setBatchCount(int batchCount)
	{
		fileList.batchCount = batchCount;
	}
}
