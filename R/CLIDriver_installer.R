# RIBMDB CLI Driver Installer file.
#

platform = .Platform$OS.type
arch = .Platform$r_arch

license_agreement = '\n\n****************************************\nYou are going to use a package which includes the R module for IBM DB2/Informix.  The module is licensed under the Apache License 2.0. The package also includes IBM ODBC and CLI Driver from IBM, which is automatically downloaded as the R module is installed on your system/device. The license agreement to the IBM ODBC and CLI Driver is available in /src/clidriver/license. Check for additional dependencies, which may come with their own license agreement(s). Your use of the components of the package and dependencies constitutes your acceptance of their respective license agreements. If you do not accept the terms of any license agreement(s), then delete the relevant component(s) from your device.\n****************************************\n'

if((nchar(arch)==0)){
  arch = R.version$arch
}
rversion = R.version.string

cat(paste("platform = " , platform , ", arch = " , arch , ", R_Version = " , rversion, "\n\n"))

install_R_ibm_db = function()
{
  endian = .Platform$endian
  
  if(platform == 'windows') {
    if(grepl("64", arch)) {
      installerfile = 'ntx64_odbc_cli.zip'
    }else{
      installerfile = 'nt32_odbc_cli.zip'
    }
  }
  else if(platform == 'linux' || platform == 'unix')
  {
    if(grepl('darwin',R.version$os))
    {
      if(grepl("64", arch)) {
        installerfile = 'macos64_odbc_cli.tar.gz'
      } else {
        cat(paste('Mac OS 32 bit not supported. Please use an ' ,
                  'x64 architecture.\n'))
        quit(status = 1)
      }
    }else if(grepl('aix',R.version$os))
    {
      if(grepl("32", system("bootinfo -y"))) {
        installerfile = 'aix32_odbc_cli.tar.gz'
      } else {
        installerfile = 'aix64_odbc_cli.tar.gz'
      }
    }else{
      if(grepl("64", arch)) {
        installerfile = 'linuxx64_odbc_cli.tar.gz'
      } else {
        installerfile = 'linuxia32_odbc_cli.tar.gz'
      }
    }
  }else{
    cat(paste('Unsupported architecture. Please use an ' ,
              'x64 architecture.\n'))
    quit(status = 1)
  }
  copyAndExtractCliDriver(installerfile)
}

copyAndExtractCliDriver = function(installerfile) {
  # Using the "unzipper" module to extract the zipped "clidriver",
  # and on successful close, printing the license_agreement
  CURRENT_DIR = getwd();
  DOWNLOAD_DIR = paste(CURRENT_DIR,'/src',sep="");
  # cat(DOWNLOAD_DIR)
  
  if(dir.exists(paste(DOWNLOAD_DIR,'/clidriver',sep=""))){
    
  }else{
    if(platform == 'windows') {
      extractCLIDriver = unzip(paste(DOWNLOAD_DIR,installerfile,sep="/"),exdir=DOWNLOAD_DIR)
    }else{
      cat("This is unix system \n")
      extractCLIDriver = untar(paste(DOWNLOAD_DIR,installerfile,sep="/"),exdir=DOWNLOAD_DIR)
    }
    
    if(dir.exists(paste(DOWNLOAD_DIR,'/clidriver',sep=""))){
      cat(license_agreement);
      cat('Downloading and extraction of DB2 ODBC CLI Driver completed successfully... \n')
      if(platform == 'linux' || platform == 'unix'){
        file.copy(paste(DOWNLOAD_DIR, 'clidriver',sep="/"), paste(CURRENT_DIR,'inst',sep="/"), recursive=TRUE)
        file.copy(paste(DOWNLOAD_DIR, 'clidriver/lib/libdb2.so.1',sep="/"),paste(CURRENT_DIR,'inst',sep="/"))
      }
      IBM_DB_HOME = paste(DOWNLOAD_DIR, '/clidriver',sep="");
      Sys.setenv("IBM_DB_HOME"=IBM_DB_HOME)
      cat(paste("<CLI_DRIVER_PATH>:",IBM_DB_HOME,"\n\n"))
      invisible(file.remove(paste(DOWNLOAD_DIR,'/aix32_odbc_cli.tar.gz',sep="")))
      invisible(file.remove(paste(DOWNLOAD_DIR,'/aix64_odbc_cli.tar.gz',sep="")))
      invisible(file.remove(paste(DOWNLOAD_DIR,'/linuxia32_odbc_cli.tar.gz',sep="")))
      invisible(file.remove(paste(DOWNLOAD_DIR,'/linuxx64_odbc_cli.tar.gz',sep="")))
      invisible(file.remove(paste(DOWNLOAD_DIR,'/macos64_odbc_cli.tar.gz',sep="")))
      invisible(file.remove(paste(DOWNLOAD_DIR,'/nt32_odbc_cli.zip',sep="")))
      invisible(file.remove(paste(DOWNLOAD_DIR,'/ntx64_odbc_cli.zip',sep="")))
    }else{
      cat('Downloading and extraction of DB2 ODBC CLI Driver unsuccessful... \n')
      quit(status = 1)
    } 
  }
}

install_R_ibm_db()