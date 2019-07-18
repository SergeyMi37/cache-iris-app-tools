Class App.Task.PurgeOldBackupFiles Extends %SYS.Task.Definition
{

Property BackupsToKeep As %Integer(MAXVAL = 30, MINVAL = 1) [ InitialExpression = 30, Required ];

Property BackupFolder As %String [ Required ];

Property BackupFileType As %String [ Required ];

Method OnTask() As %Status
{
     //s BackupsToKeep = 2
     //s Folder = "c:\backupfolder"
     //s BackupFileType = "FullAllDatabases" // or "FullDBList"

     s SortOrder = "DateModified"

     If ..BackupsToKeep<1 Quit $$$ERROR($$$GeneralError,"Invalid - Number of Backups to Keep must be greater than or equal to 1")
     If ..BackupFolder="" Quit $$$ERROR($$$GeneralError,"Invalid - BackupFolder - not supplied")
     if ..BackupFileType = "" Quit $$$ERROR($$$GeneralError,"Invalid - BackupFileType - not supplied")
     if (..BackupFileType '= "FullAllDatabases")&&(..BackupFileType '= "FullDBList") Quit $$$ERROR($$$GeneralError,"Invalid - BackupFileType")

     s BackupCount=0
     k zPurgeOldBackupFiles(..BackupFileType)
     Set rs=##class(%ResultSet).%New("%Library.File:FileSet")
     w !,"backuplist",!

     s BackupFileWildcard = ..BackupFileType _ "*.cbk"
     set status=rs.Execute(..BackupFolder, BackupFileWildcard, SortOrder)
     WHILE rs.Next() {
          Set FullFileName=rs.Data("Name")
          Set FName=##class(%File).GetFilename(FullFileName)
          Set FDateTime=##class(%File).GetFileDateModified(FullFileName)
          w "File "_FName_" "_FDateTime,!
          Set FDate=$PIECE(FDateTime,",")
          Set CDate=$PIECE($H,",")
          s BackupCount=$I(BackupCount)
          s zPurgeOldBackupFiles(..BackupFileType, BackupCount)=FullFileName 
     }
     s zPurgeOldBackupFiles(..BackupFileType, "BackupCount")=BackupCount
     do rs.Close()
     if BackupCount > ..BackupsToKeep {
          for i=1:1:BackupCount-..BackupsToKeep {
               s FullFileName = zPurgeOldBackupFiles(..BackupFileType, i)
               d ##class(%File).Delete(FullFileName)
               w "File Purged "_FullFileName_" Purged",!
          }
     }
     q status
}

}

