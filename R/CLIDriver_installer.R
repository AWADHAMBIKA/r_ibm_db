# RIBMDB CLI Driver Installer file.
#
platform = .Platform$OS.type
arch = .Platform$r_arch

CURRENT_DIR = getwd()

DOWNLOAD_DIR = paste(CURRENT_DIR,'inst',sep="/");

installerURL = 'https://public.dhe.ibm.com/ibmdl/export/pub/software/data/db2/drivers/odbc_cli/'

license_agreement = '\n\n****************************************\nYou are downloading a package which includes the R module for IBM DB2/Informix.  The module is licensed under the Apache License 2.0. The package also includes IBM ODBC and CLI Driver from IBM, which is automatically downloaded as the R module is installed on your system/device. The license agreement to the IBM ODBC and CLI Driver is available in <R_LIB_HOME>/RIBMDB/clidriver/license. Check for additional dependencies, which may come with their own license agreement(s). Your use of the components of the package and dependencies constitutes your acceptance of their respective license agreements. If you do not accept the terms of any license agreement(s), then delete the relevant component(s) from your device.\n****************************************\n'

if((nchar(arch)==0)){
  arch = R.version$arch
}
rversion = R.version.string

IBM_DB_HOME=Sys.getenv("IBM_DB_HOME")

install_R_ibm_db = function(installerURL)
{
  endian = .Platform$endian
  
  env = Sys.getenv("IBM_DB_HOME")
  
  IS_ENVIRONMENT_VAR=FALSE
  CURR_CLI_DIR=paste(CURRENT_DIR,"inst/clidriver",sep = "/")
  CLI_DIR=paste(.libPaths()[1],"RIBMDB/clidriver",sep="/")
  RIBMDB_DIR=paste(.libPaths()[1],"RIBMDB",sep="/")
  
  #Copying the so file for load test step of installation
  if(platform == 'linux' || platform == 'unix'){
    if(dir.exists(RIBMDB_DIR)){
      if(dir.exists(paste(RIBMDB_DIR,"libs",sep = "/"))){
        if(dir.exists(paste(RIBMDB_DIR,"clidriver",sep = "/"))){
          file.copy(paste(RIBMDB_DIR, 'clidriver/lib/libdb2.so.1',sep="/"),paste(RIBMDB_DIR,'libs',sep="/"))
        }
      }
    }
  }
  
  if(!(nchar(env)==0) || dir.exists(CLI_DIR) || dir.exists(CURR_CLI_DIR)){
    if((nchar(env)==0)){
      #IBM_DB_HOME = CLI_DIR
      if(dir.exists(CLI_DIR)){
        Sys.setenv("IBM_DB_HOME"=CLI_DIR)
      }else{
        Sys.setenv("IBM_DB_HOME"=CURR_CLI_DIR)
      }
    }
    IS_ENVIRONMENT_VAR = TRUE
    
    if(dir.exists(RIBMDB_DIR)){
      if(grepl('darwin',R.version$os)){
        nameToolCommand = paste("install_name_tool -change libdb2.dylib ",
                                CLI_DIR, "/lib/libdb2.dylib ", 
                                RIBMDB_DIR, "/libs/RIBMDB.so",sep="")
        cat(nameToolCommand)
        system(nameToolCommand)
      }
    }
  }
  else
  {
    cat(paste("platform = " , platform , ", arch = " , arch , ", R_Version = " , rversion, "\n\n"))
    if(platform == 'windows') {
      if(grepl("64", arch)) {
        installerfileURL = paste(installerURL , 'ntx64_odbc_cli.zip',sep="")
      }
    }
    else if(platform == 'linux' || platform == 'unix')
    {
      if(grepl('darwin',R.version$os))
      {
        if(grepl("64", arch)) {
          installerfileURL = paste(installerURL , 'macos64_odbc_cli.tar.gz',sep="")
        } else {
          cat(paste('Mac OS 32 bit not supported. Please use an ' ,
                    'x64 architecture.\n'))
          return;
        }
      }else if(grepl('aix',R.version$os))
      {
        if(grepl("32", system("bootinfo -y"))) {
            installerfileURL = paste(installerURL , 'aix32_odbc_cli.tar.gz',sep="")
        } else {
          installerfileURL = paste(installerURL , 'aix64_odbc_cli.tar.gz',sep="")
        }
      }else{
        if(grepl("64", arch)) {
          installerfileURL = paste(installerURL , 'linuxx64_odbc_cli.tar.gz',sep="")
        } else {
          installerfileURL = paste(installerURL , 'linuxia32_odbc_cli.tar.gz',sep="")
        }
      }
    }else{
      installerfileURL = paste(installerURL , platform , arch ,
                               '_odbc_cli.tar.gz',sep="")
    }
    
    library(httr)

    if(http_error(installerfileURL)) {
      cat('Unable to fetch driver download file. Exiting the install process.\n')
      quit(status = 1)
    }

    file_name = basename(installerfileURL)
    INSTALLER_FILE = paste(DOWNLOAD_DIR,file_name,sep="/")
    cat(paste('Downloading DB2 ODBC CLI Driver from ' , installerfileURL,'...\n'))
    copyAndExtractCliDriver(installerfileURL,INSTALLER_FILE)

  }  #END OF EXECUTION
}
copyAndExtractCliDriver = function(installerfileURL,INSTALLER_FILE) {
  
  # printing the license_agreement
  cat(license_agreement);
  
  # Download CLI Driver Archive
  if(platform == 'windows') {
    download.file(installerfileURL,INSTALLER_FILE,method = 'wininet',cacheOK = FALSE)
  }else{
    download.file(installerfileURL,INSTALLER_FILE,method = 'auto',cacheOK = FALSE)
  }
 
  #Extract the Archive
  if(platform == 'windows') {
    extractCLIDriver = unzip(INSTALLER_FILE,exdir=DOWNLOAD_DIR)
  }else{
    cat("This is unix system \n")
    extractCLIDriver = untar(INSTALLER_FILE,exdir=DOWNLOAD_DIR)
  }

  #Checking for successfull extraction.
  if(dir.exists(paste(DOWNLOAD_DIR,'clidriver',sep="/"))){
    cat('Downloading and extraction of DB2 ODBC CLI Driver completed successfully... \n')
    if(platform == 'windows') {
      current_folder = paste(DOWNLOAD_DIR, 'clidriver/include/',sep="/")
      list_of_files <- list.files(current_folder, ".h") 
      
      new_folder = paste(R.home(),'include',sep="/")
      # ".h" is the type of file I want to copy. Remove if copying all types of files. 
      file.copy(file.path(current_folder,list_of_files), new_folder)
       
      current_folder = paste(DOWNLOAD_DIR, 'clidriver/lib/',sep="/")
      list_of_files <- list.files(current_folder, ".lib")
      new_folder = paste(R.home(),'library',sep="/")
      file.copy(file.path(current_folder,list_of_files), new_folder)
    }
    IBM_DB_HOME = paste(.libPaths()[1], 'RIBMDB/clidriver',sep="/");
    Sys.setenv("IBM_DB_HOME"=IBM_DB_HOME)
    
    #Remove the Archive file after successfull extraction.
    invisible(file.remove(INSTALLER_FILE))
  }else{
    cat('Downloading and extraction of DB2 ODBC CLI Driver unsuccessful... \n')
    quit(status = 1)
  }
}

install_R_ibm_db(installerURL)